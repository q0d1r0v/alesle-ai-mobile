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
import '../domain/agent_status.dart';
import '../domain/live.dart';
import '../domain/server_health.dart';
import 'failure_message.dart';
import 'hands_free_controller.dart';
import 'home_providers.dart';
import 'home_task_controller.dart';
import 'live_examples.dart';
import 'task_messages.dart';

/// Home (design "Home", "Working", "Done", "Couldn't do it", "Quick answer"):
/// opening the app starts the live conversation by itself; with it ended,
/// "Talk" starts it again and a command can be typed instead.
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
      onResume: () {
        ref.invalidate(agentStatusProvider);
        unawaited(_resumeHandsFree());
      },
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_resumeHandsFree()),
    );
  }

  /// Every opening starts the live conversation (Android lets it start only
  /// while the app is in front) — once Alesle is set up: with accessibility
  /// off, the home asks for that first.
  Future<void> _resumeHandsFree() async {
    if (!mounted) return;
    final String locale = Localizations.localeOf(context).toLanguageTag();
    try {
      final AgentStatus status = await ref.read(agentStatusProvider.future);
      if (status.needsSetup || !mounted) return;
    } on Object {
      // The status is unknown: talking needs no accessibility.
    }
    if (!mounted) return;
    await ref.read(handsFreeProvider.notifier).resume(appLocale: locale);
  }

  void _showHandsFreeProblem(HandsFreeState? previous, HandsFreeState next) {
    final HandsFreeProblem? problem = next.problem;
    if (problem == null || problem == previous?.problem) return;
    if (problem == HandsFreeProblem.limitReached) {
      ref.read(handsFreeProvider.notifier).clearProblem();
      unawaited(context.push(AppRoutes.limitFor('limit_reached')));
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(switch (problem) {
            HandsFreeProblem.microphoneDenied => context.l10n.voiceMicDenied,
            HandsFreeProblem.startFailed => context.l10n.handsFreeStartFailed,
            HandsFreeProblem.limitReached => '',
          }),
        ),
      );
    ref.read(handsFreeProvider.notifier).clearProblem();
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

  @override
  Widget build(BuildContext context) {
    ref
      ..listen<HomeTask>(homeTaskProvider, _speakResult)
      ..listen<HomeTask>(homeTaskProvider, _offerMore)
      ..listen<HandsFreeState>(handsFreeProvider, _showHandsFreeProblem);
    final HomeTask task = ref.watch(homeTaskProvider);
    final bool needsSetup =
        ref.watch(agentStatusProvider).value?.needsSetup ?? false;
    final bool live =
        !needsSetup &&
        ref.watch(
          handsFreeProvider.select((HandsFreeState s) => s.inConversation),
        );
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
            child: live
                ? _LiveView(now: widget.now)
                : switch (task) {
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

  /// Starts the live conversation again (asks for the microphone if needed).
  void _talk(BuildContext context, WidgetRef ref) => unawaited(
    ref
        .read(handsFreeProvider.notifier)
        .turnOn(appLocale: Localizations.localeOf(context).toLanguageTag()),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final AsyncValue<AgentStatus> status = ref.watch(agentStatusProvider);
    final HandsFreeState handsFree = ref.watch(handsFreeProvider);
    final HandsFreeController controller = ref.read(handsFreeProvider.notifier);
    final bool muted = handsFree.phase == HandsFreePhase.muted;
    final String? heard = handsFree.heard;
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
                        label: handsFree.on
                            ? (muted
                                  ? context.l10n.handsFreeUnmute
                                  : context.l10n.handsFreeMute)
                            : context.l10n.homeTalk,
                        child: GestureDetector(
                          key: const Key('orb'),
                          // Listening one command at a time (Live is not to be had):
                          // the orb mutes; otherwise it starts the conversation.
                          onTap: () => handsFree.on
                              ? unawaited(controller.toggleMute())
                              : _talk(context, ref),
                          child: AlesleOrb(
                            size: orb,
                            level: handsFree.level,
                            state: switch (handsFree.phase) {
                              HandsFreePhase.listening => OrbState.listening,
                              HandsFreePhase.understanding => OrbState.working,
                              HandsFreePhase.muted ||
                              HandsFreePhase.off => OrbState.idle,
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        switch (handsFree.phase) {
                          HandsFreePhase.off => context.l10n.homeIdleHint,
                          HandsFreePhase.listening =>
                            handsFree.micBusy
                                ? context.l10n.liveMicBusy
                                : context.l10n.handsFreeListening,
                          HandsFreePhase.muted => context.l10n.handsFreeMuted,
                          HandsFreePhase.understanding =>
                            context.l10n.handsFreeUnderstanding,
                        },
                        key: const Key('voice-title'),
                        style: handsFree.on
                            ? text.headlineSmall?.copyWith(
                                color:
                                    handsFree.phase == HandsFreePhase.listening
                                    ? AlesleColors.violet
                                    : null,
                              )
                            : text.bodyLarge?.copyWith(
                                color: AlesleColors.text2,
                              ),
                        textAlign: TextAlign.center,
                      ),
                      if (handsFree.on && heard != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.handsFreeHeard(heard),
                          key: const Key('hands-free-heard'),
                          style: text.bodyMedium?.copyWith(
                            color: AlesleColors.text2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (handsFree.on)
                        TextButton.icon(
                          key: const Key('hands-free-mute'),
                          onPressed: () => unawaited(controller.toggleMute()),
                          icon: Icon(
                            muted ? Icons.mic_rounded : Icons.mic_off_outlined,
                            size: 18,
                          ),
                          label: Text(
                            muted
                                ? context.l10n.handsFreeUnmute
                                : context.l10n.handsFreeMute,
                          ),
                        )
                      else
                        CapsuleButton(
                          key: const Key('home-talk'),
                          label: context.l10n.homeTalk,
                          icon: Icons.mic_rounded,
                          onPressed: () => _talk(context, ref),
                        ),
                      const SizedBox(height: 4),
                      TextButton.icon(
                        key: const Key('type-instead'),
                        onPressed: () =>
                            unawaited(_askForCommand(context, ref)),
                        icon: const Icon(Icons.keyboard_outlined, size: 18),
                        label: Text(context.l10n.homeTypeInstead),
                      ),
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

// ── Live conversation ────────────────────────────────────────────────────────

/// The live conversation (SOW 04 §4.2), like a call: the orb shows who is
/// talking, the words of this turn are on screen, and phone work shows as a
/// small chip — no result screen, nothing to confirm. Mute, type, or end it.
class _LiveView extends ConsumerStatefulWidget {
  const _LiveView({required this.now});

  /// Picks which examples this opening shows; tests pin it.
  final DateTime Function() now;

  @override
  ConsumerState<_LiveView> createState() => _LiveViewState();
}

class _LiveViewState extends ConsumerState<_LiveView> {
  late final int _seed = widget.now().millisecondsSinceEpoch ~/ 1000;

  Future<void> _type(BuildContext context, WidgetRef ref) async {
    final String? text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AlesleRadii.sheet),
        ),
      ),
      builder: (BuildContext context) => const _CommandSheet(),
    );
    if (text == null || text.trim().isEmpty) return;
    await ref.read(handsFreeProvider.notifier).sendText(text);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final HandsFreeState state = ref.watch(handsFreeProvider);
    final HandsFreeController controller = ref.read(handsFreeProvider.notifier);
    final HomeTask task = ref.watch(homeTaskProvider);
    final bool muted = state.phase == HandsFreePhase.muted;
    final LiveStage stage = state.live ?? LiveStage.connecting;
    final String? said = state.said;
    final String? reply = state.reply;
    return Column(
      key: const Key('live-view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x1F7C5CE0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.graphic_eq_rounded,
                      size: 18,
                      color: AlesleColors.violet,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.liveTitle,
                      style: text.labelLarge?.copyWith(
                        color: AlesleColors.violet,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              key: const Key('home-settings'),
              onPressed: () => unawaited(context.push(AppRoutes.settings)),
              icon: const Icon(Icons.tune_rounded),
              tooltip: context.l10n.settingsTitle,
            ),
          ],
        ),
        Expanded(
          child: _Centered(
            orbFraction: 0.34,
            builder: (double orb) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AlesleOrb(
                  size: orb,
                  level: muted ? 0 : state.level,
                  state: muted || state.micBusy
                      ? OrbState.idle
                      : switch (stage) {
                          LiveStage.connecting ||
                          LiveStage.thinking => OrbState.working,
                          _ => OrbState.listening,
                        },
                ),
                const SizedBox(height: 24),
                Text(
                  muted
                      ? context.l10n.liveMuted
                      : state.micBusy
                      ? context.l10n.liveMicBusy
                      : switch (stage) {
                          LiveStage.connecting ||
                          LiveStage.unauthorized ||
                          LiveStage.fallback ||
                          LiveStage.limitReached => context.l10n.liveConnecting,
                          LiveStage.listening => context.l10n.liveListening,
                          LiveStage.hearing => context.l10n.liveHearing,
                          LiveStage.thinking => context.l10n.liveThinking,
                          LiveStage.speaking => context.l10n.liveSpeaking,
                        },
                  key: const Key('live-stage'),
                  style: text.titleMedium?.copyWith(
                    color: stage == LiveStage.hearing && !muted
                        ? AlesleColors.violet
                        : AlesleColors.text2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (said != null)
                  Text(
                    said,
                    key: const Key('live-said'),
                    style: text.bodyLarge?.copyWith(color: AlesleColors.text2),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (reply != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    reply,
                    key: const Key('live-reply'),
                    style: text.titleLarge,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (said == null && reply == null) ...<Widget>[
                  Text(
                    context.l10n.liveHint,
                    style: text.bodyLarge?.copyWith(color: AlesleColors.text2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.liveExamplesTitle,
                    style: text.bodyMedium?.copyWith(color: AlesleColors.text2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final (int i, String example) in pickExamples(
                        liveExamples(context.l10n),
                        _seed,
                      ).indexed)
                        _Chip(
                          key: ValueKey<String>('live-example-$i'),
                          label: example,
                          onTap: () => unawaited(controller.sendText(example)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        if (task is TaskRunning) ...<Widget>[
          Center(
            child: InputChip(
              key: const Key('live-task'),
              avatar: const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: Text(
                context.l10n.liveTaskRunning(task.step ?? task.command),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              deleteIcon: const Icon(Icons.close_rounded, size: 18),
              deleteButtonTooltipMessage: context.l10n.liveTaskStop,
              onDeleted: () =>
                  unawaited(ref.read(homeTaskProvider.notifier).stop()),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: _LiveButton(
                key: const Key('live-mute'),
                icon: muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                label: muted
                    ? context.l10n.handsFreeUnmute
                    : context.l10n.handsFreeMute,
                selected: muted,
                onPressed: () => unawaited(controller.toggleMute()),
              ),
            ),
            Expanded(
              child: _LiveButton(
                key: const Key('live-keyboard'),
                icon: Icons.keyboard_outlined,
                label: context.l10n.liveKeyboard,
                onPressed: () => unawaited(_type(context, ref)),
              ),
            ),
            Expanded(
              child: _LiveButton(
                key: const Key('live-close'),
                icon: Icons.close_rounded,
                label: context.l10n.liveClose,
                danger: true,
                onPressed: () => unawaited(controller.turnOff()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiveButton extends StatelessWidget {
  const _LiveButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color background = danger
        ? AlesleColors.danger
        : selected
        ? AlesleColors.ink
        : Colors.white;
    final Color foreground = danger || selected
        ? Colors.white
        : AlesleColors.ink;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          button: true,
          label: label,
          child: Material(
            color: background,
            shape: const CircleBorder(),
            elevation: 1,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox.square(
                dimension: 64,
                child: Icon(icon, color: foreground, size: 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AlesleColors.text2),
        ),
      ],
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
                if (ref.watch(
                  handsFreeProvider.select((s) => s.on),
                )) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.handsFreeWhileRunning,
                    key: const Key('hands-free-running-hint'),
                    style: text.bodyMedium?.copyWith(color: AlesleColors.text2),
                    textAlign: TextAlign.center,
                  ),
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
