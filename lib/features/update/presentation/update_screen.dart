import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/alesle_orb.dart';
import '../../../app/widgets/capsule_button.dart';
import '../../../core/config/app_build.dart';
import '../../../core/errors/failure.dart';
import '../domain/update.dart';
import 'update_controller.dart';

/// The installed version and, when there is one, the update (SOW 02 §3).
/// [mandatory]: this version is no longer served (EC-15) — no way back.
/// [start]: begin downloading at once (the "new version" sheet's Update).
class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({super.key, this.mandatory = false, this.start = false});

  final bool mandatory;
  final bool start;

  @override
  ConsumerState<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  bool _started = false;

  void _maybeStart(Release? release) {
    if (!widget.start || _started || release == null) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(updateFlowProvider.notifier).run(release));
    });
  }

  String? _message(AppLocalizations l10n, UpdateFlow flow) => switch (flow) {
    UpdateIdle() => null,
    UpdateDownloading(:final double progress) => l10n.updateDownloading(
      (progress * 100).round(),
    ),
    UpdateInstalling() => l10n.updateInstalling,
    UpdateFinished(:final InstallResult result) => switch (result) {
      InstallResult.started => l10n.updateStarted,
      InstallResult.permissionNeeded => l10n.updatePermissionNeeded,
      InstallResult.corrupted || InstallResult.rejected => l10n.updateRejected,
      InstallResult.failed => l10n.updateFailed,
    },
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    final AppBuild build = ref.watch(appBuildProvider);
    final AsyncValue<Release?> latest = ref.watch(latestReleaseProvider);
    final UpdateFlow flow = ref.watch(updateFlowProvider);
    final bool busy = flow is UpdateDownloading || flow is UpdateInstalling;
    final Release? release = latest.value;
    _maybeStart(release);
    final UpdateNeed need = updateNeed(build.versionCode, release);
    final bool offer = need != UpdateNeed.none || widget.mandatory;
    final String language = Localizations.localeOf(context).languageCode;
    final String? status = _message(l10n, flow);

    final Widget body = Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AlesleOrb(
                      state: busy ? OrbState.working : OrbState.idle,
                      size: 140,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      offer ? l10n.updateAvailableTitle : l10n.updateUpToDate,
                      key: const Key('update-title'),
                      style: text.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    if (offer)
                      Text(
                        widget.mandatory || need == UpdateNeed.required
                            ? l10n.updateRequiredBody
                            : l10n.updateAvailableBody,
                        style: text.bodyLarge?.copyWith(
                          color: AlesleColors.text2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16),
                    if (build.known)
                      Text(
                        l10n.updateVersion(
                          '${build.versionName} (${build.versionCode})',
                        ),
                        key: const Key('update-installed'),
                        style: text.bodyMedium?.copyWith(
                          color: AlesleColors.text2,
                        ),
                      ),
                    if (release != null && offer) ...<Widget>[
                      Text(
                        l10n.updateNewVersion(release.versionName),
                        key: const Key('update-new'),
                        style: text.bodyMedium,
                      ),
                      if (release.notesIn(language).isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          release.notesIn(language),
                          style: text.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                    if (latest.hasError) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        latest.error is NetworkFailure
                            ? l10n.errorNetwork
                            : l10n.updateFailed,
                        key: const Key('update-error'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (status != null) ...<Widget>[
                      const SizedBox(height: 16),
                      Text(
                        status,
                        key: const Key('update-status'),
                        style: text.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (flow case UpdateDownloading(:final double progress))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(value: progress),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (release != null && offer)
            CapsuleButton(
              key: const Key('update-now'),
              label: l10n.updateNow,
              onPressed: busy
                  ? null
                  : () => unawaited(
                      ref.read(updateFlowProvider.notifier).run(release),
                    ),
            )
          else if (latest.hasError || (widget.mandatory && release == null))
            CapsuleButton(
              key: const Key('update-retry'),
              label: l10n.commonRetry,
              onPressed: () => ref.invalidate(latestReleaseProvider),
            ),
        ],
      ),
    );

    if (widget.mandatory) {
      return PopScope(
        canPop: false,
        child: Scaffold(body: SafeArea(child: body)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.updateTitle)),
      body: SafeArea(top: false, child: body),
    );
  }
}
