import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/alesle_orb.dart';
import '../../../app/widgets/capsule_button.dart';
import '../../../core/errors/failure.dart';
import '../../../core/storage/app_settings.dart';
import '../data/onboarding_data_providers.dart';
import '../domain/device_setup.dart';

/// Onboarding (SOW 09 §2; design "start page"): one screen per step, each
/// checked against the phone; "Later" skips without lying about the state.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final AppLifecycleListener _lifecycle;
  OnboardingStep _step = OnboardingStep.welcome;
  final Map<SetupPermission, PermissionStatus> _permissions =
      <SetupPermission, PermissionStatus>{};
  bool _accessibility = false;
  DeviceSetup? _setup;

  DeviceSetupRepository get _repository =>
      ref.read(deviceSetupRepositoryProvider);

  @override
  void initState() {
    super.initState();
    // The user grants things in system screens and comes back: re-read then.
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_refresh()));
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final Map<SetupPermission, PermissionStatus> statuses =
          <SetupPermission, PermissionStatus>{
            for (final SetupPermission permission in SetupPermission.values)
              permission: await _repository.status(permission),
          };
      final bool accessibility = await _repository.accessibilityEnabled();
      final DeviceSetup setup = await _repository.setup();
      if (!mounted) return;
      setState(() {
        _permissions
          ..clear()
          ..addAll(statuses);
        _accessibility = accessibility;
        _setup = setup;
      });
      // Turned on in Settings and came back: that step is done.
      if (_step == OnboardingStep.accessibility && accessibility) _next();
    } on Failure {
      // The bridge is not there (tests, a broken install): steps stay as they are.
    }
  }

  void _next() {
    final int index = OnboardingStep.values.indexOf(_step);
    if (index + 1 < OnboardingStep.values.length) {
      setState(() => _step = OnboardingStep.values[index + 1]);
    }
  }

  void _back() {
    final int index = OnboardingStep.values.indexOf(_step);
    if (index > 0) setState(() => _step = OnboardingStep.values[index - 1]);
  }

  Future<void> _finish() async {
    await ref
        .read(appSettingsProvider.notifier)
        .update(
          (AppSettings settings) => settings.copyWith(onboardingDone: true),
        );
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _askPermissions() async {
    for (final SetupPermission permission in SetupPermission.values) {
      final PermissionStatus current =
          _permissions[permission] ?? PermissionStatus.denied;
      if (current == PermissionStatus.granted) continue;
      if (current == PermissionStatus.permanentlyDenied) {
        await _repository.openAppDetails();
        return;
      }
      final PermissionStatus answer = await _repository.request(permission);
      if (!mounted) return;
      setState(() => _permissions[permission] = answer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == OnboardingStep.welcome,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: switch (_step) {
              OnboardingStep.welcome => _Welcome(onStart: _next),
              OnboardingStep.language => _Language(
                onBack: _back,
                onContinue: _next,
              ),
              OnboardingStep.privacy => _Privacy(
                onBack: _back,
                onContinue: _next,
              ),
              OnboardingStep.permissions => _Permissions(
                statuses: _permissions,
                onBack: _back,
                onAllow: () => unawaited(_askPermissions()),
                onContinue: _next,
              ),
              OnboardingStep.accessibility => _TurnOn(
                enabled: _accessibility,
                mayRestrict: _setup?.mayRestrictSettings ?? true,
                onBack: _back,
                onOpenSettings: () =>
                    unawaited(_repository.openAccessibilitySettings()),
                onOpenAppInfo: () => unawaited(_repository.openAppDetails()),
                onContinue: _next,
              ),
              OnboardingStep.battery => _Battery(
                setup: _setup,
                onBack: _back,
                onExempt: () =>
                    unawaited(_repository.requestBatteryExemption()),
                onAutostart: () => unawaited(_repository.openAutostart()),
                onContinue: _next,
              ),
              OnboardingStep.done => _Done(
                onFinish: () => unawaited(_finish()),
              ),
            },
          ),
        ),
      ),
    );
  }
}

// ── Layout ───────────────────────────────────────────────────────────────────

/// Back arrow, large title, subtitle, content, then the actions at the bottom.
class _StepLayout extends StatelessWidget {
  const _StepLayout({
    required this.title,
    required this.content,
    required this.primary,
    this.body,
    this.onBack,
    this.secondary,
  });

  final String title;
  final String? body;
  final Widget content;
  final Widget primary;
  final Widget? secondary;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (onBack != null)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton.filledTonal(
              key: const Key('onboarding-back'),
              style: IconButton.styleFrom(backgroundColor: Colors.white),
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(title, style: text.headlineLarge),
                if (body case final String value) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: text.bodyLarge?.copyWith(color: AlesleColors.text2),
                  ),
                ],
                const SizedBox(height: 24),
                content,
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        primary,
        if (secondary case final Widget value) ...<Widget>[
          const SizedBox(height: 4),
          value,
        ],
      ],
    );
  }
}

/// The white grouped list of the design system.
/// A white rounded card; its own [Material] so list tiles inside show ink.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AlesleRadii.card);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AlesleShadows.card,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: <Widget>[
          for (final (int index, Widget child) in children.indexed) ...<Widget>[
            if (index > 0)
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: AlesleColors.hairline,
              ),
            child,
          ],
        ],
      ),
    );
  }
}

// ── Steps ────────────────────────────────────────────────────────────────────

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AlesleOrb(
                          size: (constraints.maxHeight * 0.32).clamp(
                            96.0,
                            200.0,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          context.l10n.onboardingWelcomeTitle,
                          style: text.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.l10n.onboardingWelcomeBody,
                          style: text.bodyLarge?.copyWith(
                            color: AlesleColors.text2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ),
        CapsuleButton(
          key: const Key('onboarding-start'),
          label: context.l10n.onboardingGetStarted,
          onPressed: onStart,
        ),
      ],
    );
  }
}

class _Language extends ConsumerWidget {
  const _Language({required this.onBack, required this.onContinue});

  final VoidCallback onBack;
  final VoidCallback onContinue;

  static const List<(String, String)> _options = <(String, String)>[
    ('uz', 'O‘zbekcha'),
    ('ru', 'Русский'),
    ('en', 'English'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String current = Localizations.localeOf(context).languageCode;
    return _StepLayout(
      onBack: onBack,
      title: context.l10n.onboardingLanguageTitle,
      body: context.l10n.onboardingLanguageBody,
      content: _Group(
        children: <Widget>[
          for (final (String code, String name) in _options)
            ListTile(
              key: Key('language-$code'),
              title: Text(name, style: Theme.of(context).textTheme.titleMedium),
              trailing: current == code
                  ? const Icon(Icons.check_circle, color: AlesleColors.violet)
                  : null,
              onTap: () => unawaited(
                ref
                    .read(appSettingsProvider.notifier)
                    .update(
                      (AppSettings settings) =>
                          settings.copyWith(language: code),
                    ),
              ),
            ),
        ],
      ),
      primary: CapsuleButton(
        key: const Key('onboarding-continue'),
        label: context.l10n.onboardingContinue,
        onPressed: onContinue,
      ),
    );
  }
}

class _Privacy extends StatelessWidget {
  const _Privacy({required this.onBack, required this.onContinue});

  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final List<(IconData, String)> points = <(IconData, String)>[
      (Icons.touch_app_outlined, context.l10n.onboardingPrivacyPoint1),
      (Icons.visibility_off_outlined, context.l10n.onboardingPrivacyPoint2),
      (Icons.front_hand_outlined, context.l10n.onboardingPrivacyPoint3),
    ];
    return _StepLayout(
      onBack: onBack,
      title: context.l10n.onboardingPrivacyTitle,
      content: _Group(
        children: <Widget>[
          for (final (IconData icon, String text) in points)
            ListTile(
              leading: _Tile(icon: icon, gradient: AlesleColors.violetGradient),
              title: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
        ],
      ),
      primary: CapsuleButton(
        key: const Key('onboarding-continue'),
        label: context.l10n.onboardingContinue,
        onPressed: onContinue,
      ),
    );
  }
}

class _Permissions extends StatelessWidget {
  const _Permissions({
    required this.statuses,
    required this.onBack,
    required this.onAllow,
    required this.onContinue,
  });

  final Map<SetupPermission, PermissionStatus> statuses;
  final VoidCallback onBack;
  final VoidCallback onAllow;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final List<(SetupPermission, IconData, Gradient, String, String)> rows =
        <(SetupPermission, IconData, Gradient, String, String)>[
          (
            SetupPermission.microphone,
            Icons.mic_none_rounded,
            AlesleColors.violetGradient,
            context.l10n.permissionMicrophone,
            context.l10n.permissionMicrophoneWhy,
          ),
          (
            SetupPermission.contacts,
            Icons.person_outline_rounded,
            AlesleColors.doneGradient,
            context.l10n.permissionContacts,
            context.l10n.permissionContactsWhy,
          ),
          (
            SetupPermission.notifications,
            Icons.notifications_none_rounded,
            const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFFFF8A80), Color(0xFFE5534B)],
            ),
            context.l10n.permissionNotifications,
            context.l10n.permissionNotificationsWhy,
          ),
        ];
    final bool allGranted = SetupPermission.values.every(
      (SetupPermission permission) =>
          statuses[permission] == PermissionStatus.granted,
    );
    final bool blocked = statuses.values.contains(
      PermissionStatus.permanentlyDenied,
    );
    return _StepLayout(
      onBack: onBack,
      title: context.l10n.onboardingPermissionsTitle,
      body: context.l10n.onboardingPermissionsBody,
      content: _Group(
        children: <Widget>[
          for (final (
                SetupPermission permission,
                IconData icon,
                Gradient gradient,
                String name,
                String why,
              )
              in rows)
            ListTile(
              key: Key('permission-${permission.name}'),
              leading: _Tile(icon: icon, gradient: gradient),
              title: Text(name, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(why),
              trailing: statuses[permission] == PermissionStatus.granted
                  ? const Icon(
                      Icons.check_circle,
                      color: AlesleColors.doneBottom,
                    )
                  : null,
            ),
        ],
      ),
      primary: allGranted
          ? CapsuleButton(
              key: const Key('onboarding-continue'),
              label: context.l10n.onboardingContinue,
              onPressed: onContinue,
            )
          : CapsuleButton(
              key: const Key('permissions-allow'),
              label: blocked
                  ? context.l10n.permissionOpenSettings
                  : context.l10n.permissionAllow,
              onPressed: onAllow,
            ),
      secondary: allGranted
          ? null
          : CapsuleButton(
              key: const Key('onboarding-later'),
              label: context.l10n.onboardingLater,
              style: CapsuleStyle.text,
              onPressed: onContinue,
            ),
    );
  }
}

class _TurnOn extends StatelessWidget {
  const _TurnOn({
    required this.enabled,
    required this.mayRestrict,
    required this.onBack,
    required this.onOpenSettings,
    required this.onOpenAppInfo,
    required this.onContinue,
  });

  final bool enabled;
  final bool mayRestrict;
  final VoidCallback onBack;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAppInfo;
  final VoidCallback onContinue;

  void _showRestrictedHelp(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        // Four steps and a button outgrow the default 9/16 height on small
        // phones or with large text: size to content, scroll beyond it.
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AlesleRadii.sheet),
          ),
        ),
        builder: (BuildContext sheet) {
          final List<String> steps = <String>[
            sheet.l10n.restrictedStep1,
            sheet.l10n.restrictedStep2,
            sheet.l10n.restrictedStep3,
            sheet.l10n.restrictedStep4,
          ];
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  sheet.l10n.restrictedTitle,
                  style: Theme.of(sheet).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                for (final (int index, String step) in steps.indexed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: AlesleColors.capsuleGrey,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(step),
                  ),
                const SizedBox(height: 8),
                CapsuleButton(
                  key: const Key('restricted-open-app-info'),
                  label: sheet.l10n.restrictedOpen,
                  onPressed: () {
                    Navigator.of(sheet).pop();
                    onOpenAppInfo();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      onBack: onBack,
      title: context.l10n.turnOnTitle,
      body: context.l10n.turnOnBody,
      content: _Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: const AlesleOrb(size: 40),
          title: Text(
            context.l10n.appTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          trailing: Switch(value: enabled, onChanged: null),
        ),
      ),
      primary: enabled
          ? CapsuleButton(
              key: const Key('onboarding-continue'),
              label: context.l10n.onboardingContinue,
              onPressed: onContinue,
            )
          : CapsuleButton(
              key: const Key('turn-on-open-settings'),
              label: context.l10n.turnOnButton,
              onPressed: onOpenSettings,
            ),
      secondary: enabled
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (mayRestrict)
                  CapsuleButton(
                    key: const Key('turn-on-grey-help'),
                    label: context.l10n.turnOnGreyHelp,
                    style: CapsuleStyle.text,
                    onPressed: () => _showRestrictedHelp(context),
                  ),
                CapsuleButton(
                  key: const Key('onboarding-later'),
                  label: context.l10n.onboardingLater,
                  style: CapsuleStyle.text,
                  onPressed: onContinue,
                ),
              ],
            ),
    );
  }
}

class _Battery extends StatelessWidget {
  const _Battery({
    required this.setup,
    required this.onBack,
    required this.onExempt,
    required this.onAutostart,
    required this.onContinue,
  });

  final DeviceSetup? setup;
  final VoidCallback onBack;
  final VoidCallback onExempt;
  final VoidCallback onAutostart;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final bool exempt = setup?.batteryOptimizationIgnored ?? false;
    return _StepLayout(
      onBack: onBack,
      title: context.l10n.onboardingBatteryTitle,
      body: context.l10n.onboardingBatteryBody,
      content: _Group(
        children: <Widget>[
          ListTile(
            key: const Key('battery-exempt'),
            leading: const _Tile(
              icon: Icons.battery_charging_full_rounded,
              gradient: AlesleColors.doneGradient,
            ),
            title: Text(context.l10n.onboardingBatteryButton),
            trailing: exempt
                ? const Icon(Icons.check_circle, color: AlesleColors.doneBottom)
                : const Icon(Icons.chevron_right_rounded),
            onTap: exempt ? null : onExempt,
          ),
          if (setup?.hasAutostartScreen ?? false)
            ListTile(
              key: const Key('battery-autostart'),
              leading: const _Tile(
                icon: Icons.restart_alt_rounded,
                gradient: AlesleColors.notDoneGradient,
              ),
              title: Text(context.l10n.onboardingAutostartButton),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: onAutostart,
            ),
        ],
      ),
      primary: CapsuleButton(
        key: const Key('onboarding-continue'),
        label: context.l10n.onboardingContinue,
        onPressed: onContinue,
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const AlesleOrb(state: OrbState.done, size: 110),
                  const SizedBox(height: 28),
                  Text(
                    context.l10n.onboardingDoneTitle,
                    style: text.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.onboardingDoneBody,
                    style: text.bodyLarge?.copyWith(color: AlesleColors.text2),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        CapsuleButton(
          key: const Key('onboarding-finish'),
          label: context.l10n.onboardingDoneButton,
          onPressed: onFinish,
        ),
      ],
    );
  }
}

/// The design's gradient icon tile.
class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.gradient});

  final IconData icon;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}
