import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/alesle_orb.dart';
import '../../../app/widgets/capsule_button.dart';
import '../../../core/agent/agent_task.dart';
import '../../../core/errors/failure.dart';
import '../domain/agent_status.dart';
import '../domain/server_health.dart';
import 'failure_message.dart';
import 'home_providers.dart';
import 'home_task_controller.dart';
import 'task_messages.dart';
import 'voice_controller.dart';

/// Home (design "Home", "Working", "Done", "Couldn't do it", "Quick answer"):
/// the orb takes a command, follows the task, and shows how it ended.
/// Voice arrives in Sprint 4; until then the orb opens a text field.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.now = DateTime.now});

  /// Clock for the greeting; tests pin it.
  final DateTime Function() now;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The user enables accessibility in system settings and comes back:
    // re-read the status then, not on a timer.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(agentStatusProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// The agent's reply, read aloud unless the user chose silence.
  void _speakResult(HomeTask? previous, HomeTask next) {
    if (next is! TaskResult || previous is TaskResult) return;
    final String? reply = next.reply;
    if (reply == null || reply.trim().isEmpty) return;
    if (!ref.read(appSettingsProvider).voiceReplies) return;
    unawaited(
      ref.read(voiceRepositoryProvider).speak(reply).catchError((Object _) {
        // A silent reply is still on screen; nothing to tell the user.
      }),
    );
  }

  /// A task refused for the plan's limit opens the limit screen (SOW 07 §6).
  void _offerMore(HomeTask? previous, HomeTask next) {
    if (next is! TaskResult || previous is TaskResult) return;
    final String? reason = next.reason;
    if (!isLimitReason(reason)) return;
    unawaited(context.push(AppRoutes.limitFor(reason!)));
  }

  void _showVoiceProblem(VoiceState? previous, VoiceState next) {
    final VoiceProblem? problem = next.problem;
    if (problem == null || problem == previous?.problem) return;
    final String message = switch (problem) {
      VoiceProblem.microphoneDenied => context.l10n.voiceMicDenied,
      VoiceProblem.notHeard => context.l10n.voiceNotHeard,
      VoiceProblem.failed => failureMessage(
        context.l10n,
        next.failure ?? const UnexpectedFailure('voice'),
      ),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    ref.read(voiceProvider.notifier).clearProblem();
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen<HomeTask>(homeTaskProvider, _speakResult)
      ..listen<HomeTask>(homeTaskProvider, _offerMore)
      ..listen<VoiceState>(voiceProvider, _showVoiceProblem);
    final HomeTask task = ref.watch(homeTaskProvider);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.25),
            radius: 0.9,
            colors: <Color>[Color(0x33A089F0), AlesleColors.canvas],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: switch (task) {
              TaskIdle() => _IdleView(now: widget.now),
              final TaskRunning running => _RunningView(task: running),
              final TaskResult result => _ResultView(result: result),
            },
          ),
        ),
      ),
    );
  }
}

// ── Idle ─────────────────────────────────────────────────────────────────────

class _IdleView extends ConsumerWidget {
  const _IdleView({required this.now});

  final DateTime Function() now;

  /// The editable command sheet; [initial] is what voice heard (R6, EC-13).
  Future<void> _askForCommand(
    BuildContext context,
    WidgetRef ref, {
    String initial = '',
  }) async {
    final String? text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AlesleRadii.sheet),
        ),
      ),
      builder: (BuildContext context) => _CommandSheet(initial: initial),
    );
    if (text == null || text.trim().isEmpty || !context.mounted) return;
    await ref
        .read(homeTaskProvider.notifier)
        .start(
          TaskCommand(
            text: text,
            locale: Localizations.localeOf(context).toLanguageTag(),
            confirmSensitiveActions:
                ref.read(executionPolicyProvider) ==
                ExecutionPolicy.confirmSensitiveActions,
          ),
        );
  }

  Future<void> _onOrb(BuildContext context, WidgetRef ref) async {
    final String language = Localizations.localeOf(context).languageCode;
    final String? heard = await ref
        .read(voiceProvider.notifier)
        .toggle(language: language);
    if (heard != null && context.mounted) {
      await _askForCommand(context, ref, initial: heard);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final AsyncValue<AgentStatus> status = ref.watch(agentStatusProvider);
    final VoicePhase phase = ref.watch(
      voiceProvider.select((VoiceState state) => state.phase),
    );
    final bool off = status.value?.needsSetup ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              // Debug builds: a long press opens the agent console.
              child: GestureDetector(
                key: const Key('home-title'),
                onLongPress: kDebugMode
                    ? () => unawaited(context.push(AppRoutes.agentDebug))
                    : null,
                child: Text(
                  greeting(context.l10n, now()),
                  style: text.bodyLarge?.copyWith(color: AlesleColors.text2),
                ),
              ),
            ),
            IconButton(
              key: const Key('home-settings'),
              onPressed: () => unawaited(context.push(AppRoutes.settings)),
              icon: const Icon(Icons.tune_rounded),
              tooltip: context.l10n.settingsTitle,
            ),
          ],
        ),
        Expanded(
          child: off
              ? const _OffView()
              : _Centered(
                  builder: (double orb) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Semantics(
                        button: true,
                        label: phase == VoicePhase.listening
                            ? context.l10n.homeTapToStop
                            : context.l10n.homeTapToSpeak,
                        child: GestureDetector(
                          key: const Key('orb'),
                          onTap: () => unawaited(_onOrb(context, ref)),
                          // Hold to talk: listening while the finger is down.
                          onLongPressStart: (_) {
                            if (ref.read(voiceProvider).phase ==
                                VoicePhase.idle) {
                              unawaited(_onOrb(context, ref));
                            }
                          },
                          onLongPressEnd: (_) {
                            if (ref.read(voiceProvider).phase ==
                                VoicePhase.listening) {
                              unawaited(_onOrb(context, ref));
                            }
                          },
                          child: AlesleOrb(
                            size: orb,
                            state: switch (phase) {
                              VoicePhase.idle => OrbState.idle,
                              VoicePhase.listening => OrbState.listening,
                              VoicePhase.transcribing => OrbState.working,
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        switch (phase) {
                          VoicePhase.idle => context.l10n.homeTapToSpeak,
                          VoicePhase.listening => context.l10n.homeListening,
                          VoicePhase.transcribing =>
                            context.l10n.homeUnderstanding,
                        },
                        key: const Key('voice-title'),
                        style: text.headlineSmall?.copyWith(
                          color: phase == VoicePhase.listening
                              ? AlesleColors.violet
                              : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      if (phase == VoicePhase.listening)
                        _Chip(
                          key: const Key('voice-stop-chip'),
                          label: context.l10n.homeTapToStop,
                          onTap: () => unawaited(_onOrb(context, ref)),
                        )
                      else if (phase == VoicePhase.idle) ...<Widget>[
                        _Chip(
                          key: const Key('example-chip'),
                          label: context.l10n.homeExample,
                          onTap: () => unawaited(_askForCommand(context, ref)),
                        ),
                        TextButton.icon(
                          key: const Key('type-instead'),
                          onPressed: () =>
                              unawaited(_askForCommand(context, ref)),
                          icon: const Icon(Icons.keyboard_outlined, size: 18),
                          label: Text(context.l10n.homeTypeInstead),
                        ),
                      ],
                      const SizedBox(height: 8),
                      const _ServerProblem(),
                    ],
                  ),
                ),
        ),
        if (status.error case final Object error)
          Text(
            failureMessage(context.l10n, error),
            key: const Key('agent-status-error'),
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: AlesleColors.danger),
          ),
      ],
    );
  }
}

/// Design "Alesle is off": the accessibility switch is off (AC-APP-2, EC-11).
class _OffView extends ConsumerWidget {
  const _OffView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      key: const Key('off-view'),
      children: <Widget>[
        Expanded(
          child: _Centered(
            builder: (double orb) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Opacity(
                  opacity: 0.35,
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.33, 0.33, 0.33, 0, 0, //
                      0.33, 0.33, 0.33, 0, 0, //
                      0.33, 0.33, 0.33, 0, 0, //
                      0, 0, 0, 1, 0,
                    ]),
                    child: AlesleOrb(size: orb),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  context.l10n.offTitle,
                  style: text.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.offBody,
                  style: text.bodyLarge?.copyWith(color: AlesleColors.text2),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        CapsuleButton(
          key: const Key('enable-accessibility-button'),
          label: context.l10n.offButton,
          onPressed: () => unawaited(
            ref.read(agentRepositoryProvider).openAccessibilitySettings(),
          ),
        ),
      ],
    );
  }
}

/// Shown only when the API cannot be reached; a healthy server is silent.
class _ServerProblem extends ConsumerWidget {
  const _ServerProblem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ServerHealth> health = ref.watch(serverHealthProvider);
    // Riverpod retries a failed provider; while it does, the value is
    // loading *with* the error, which must still show.
    final Object? error = health.error;
    final ServerHealth? value = health.value;
    final String? problem = error != null
        ? failureMessage(context.l10n, error)
        : (value != null && !value.isReady
              ? context.l10n.serverUnavailable
              : null);
    if (problem == null) return const SizedBox.shrink();
    return Row(
      key: const Key('server-problem'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.cloud_off_outlined,
          size: 18,
          color: AlesleColors.text2,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            problem,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AlesleColors.text2),
          ),
        ),
        TextButton(
          onPressed: () => ref.invalidate(serverHealthProvider),
          child: Text(context.l10n.retry),
        ),
      ],
    );
  }
}

class _CommandSheet extends StatefulWidget {
  const _CommandSheet({this.initial = ''});

  /// What voice heard; the user can correct it before sending.
  final String initial;

  @override
  State<_CommandSheet> createState() => _CommandSheetState();
}

class _CommandSheetState extends State<_CommandSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            key: const Key('command-field'),
            controller: _controller,
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(hintText: context.l10n.commandHint),
          ),
          const SizedBox(height: 14),
          ListenableBuilder(
            listenable: _controller,
            builder: (BuildContext context, Widget? child) => CapsuleButton(
              key: const Key('send-button'),
              label: context.l10n.commandSend,
              onPressed: _controller.text.trim().isEmpty ? null : _send,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Running ──────────────────────────────────────────────────────────────────

class _RunningView extends ConsumerWidget {
  const _RunningView({required this.task});

  final TaskRunning task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: _Centered(
            orbFraction: 0.26,
            builder: (double orb) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AlesleOrb(state: OrbState.working, size: orb),
                const SizedBox(height: 32),
                Text(
                  task.step ?? context.l10n.taskWorking,
                  key: const Key('task-step'),
                  style: text.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (task.command.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  _Chip(label: task.command),
                ],
              ],
            ),
          ),
        ),
        CapsuleButton(
          key: const Key('stop-button'),
          label: context.l10n.taskStop,
          icon: Icons.stop_rounded,
          onPressed: () =>
              unawaited(ref.read(homeTaskProvider.notifier).stop()),
        ),
      ],
    );
  }
}

// ── Result ───────────────────────────────────────────────────────────────────

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.result});

  final TaskResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final CapsuleButton done = CapsuleButton(
      key: const Key('done-button'),
      label: context.l10n.taskDoneButton,
      onPressed: ref.read(homeTaskProvider.notifier).dismiss,
    );

    if (result.isQuickAnswer) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 24),
          Text(
            context.l10n.taskYouSaid,
            style: text.bodyMedium?.copyWith(color: AlesleColors.text2),
          ),
          const SizedBox(height: 6),
          Text('“${result.command}”', style: text.titleLarge),
          Expanded(
            child: _Centered(
              builder: (_) => SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  key: const Key('quick-answer'),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AlesleRadii.card),
                    boxShadow: AlesleShadows.card,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(result.reply!, style: text.bodyLarge),
                  ),
                ),
              ),
            ),
          ),
          done,
        ],
      );
    }

    final bool succeeded = result.outcome == TaskOutcome.done;
    final String? explanation = taskExplanation(
      context.l10n,
      outcome: result.outcome,
      reason: result.reason,
      reply: result.reply,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: _Centered(
            orbFraction: 0.2,
            builder: (double orb) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AlesleOrb(
                  state: succeeded ? OrbState.done : OrbState.notDone,
                  size: orb,
                ),
                const SizedBox(height: 28),
                Text(
                  succeeded
                      ? (result.reply ?? context.l10n.taskDoneTitle)
                      : taskTitle(context.l10n, result.outcome),
                  key: const Key('result-title'),
                  style: text.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                if (explanation != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    explanation,
                    key: const Key('result-explanation'),
                    style: text.bodyLarge?.copyWith(color: AlesleColors.text2),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (succeeded && result.command.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  _Chip(label: result.command),
                ],
              ],
            ),
          ),
        ),
        if (isLimitReason(result.reason)) ...<Widget>[
          CapsuleButton(
            key: const Key('result-add-more'),
            label: context.l10n.taskAddMore,
            onPressed: () =>
                unawaited(context.push(AppRoutes.limitFor(result.reason!))),
          ),
          const SizedBox(height: 8),
          CapsuleButton(
            key: const Key('done-button'),
            label: context.l10n.taskDoneButton,
            style: CapsuleStyle.text,
            onPressed: ref.read(homeTaskProvider.notifier).dismiss,
          ),
        ] else
          done,
      ],
    );
  }
}

/// Centers [builder]'s content in the space left; scrolls instead of
/// overflowing when that space is short (split screen, large fonts). The orb
/// shrinks with the space: [builder] gets its size.
class _Centered extends StatelessWidget {
  const _Centered({required this.builder, this.orbFraction = 0.32});

  final Widget Function(double orbSize) builder;
  final double orbFraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double orb = (constraints.maxHeight * orbFraction).clamp(
          72.0,
          200.0,
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: builder(orb)),
          ),
        );
      },
    );
  }
}

/// The small white pill under titles: an example, the command, a detail.
class _Chip extends StatelessWidget {
  const _Chip({required this.label, super.key, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
