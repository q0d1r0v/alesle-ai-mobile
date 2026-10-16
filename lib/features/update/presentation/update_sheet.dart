import 'package:flutter/material.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/capsule_button.dart';
import '../domain/update.dart';

/// "A new version is here" (design "New version"): true when the user chose
/// to update now.
Future<bool> showUpdateSheet(BuildContext context, Release release) async {
  final bool? update = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheet) {
      final AppLocalizations l10n = sheet.l10n;
      final TextTheme text = Theme.of(sheet).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AlesleColors.violetGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.updateAvailableTitle,
                key: const Key('update-sheet-title'),
                style: text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '${l10n.updateNewVersion(release.versionName)} · '
                '${l10n.updateAvailableBody}',
                style: text.bodyMedium?.copyWith(color: AlesleColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: CapsuleButton(
                      key: const Key('update-sheet-later'),
                      label: l10n.commonLater,
                      style: CapsuleStyle.secondary,
                      onPressed: () => Navigator.of(sheet).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CapsuleButton(
                      key: const Key('update-sheet-update'),
                      label: l10n.updateNow,
                      onPressed: () => Navigator.of(sheet).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return update ?? false;
}
