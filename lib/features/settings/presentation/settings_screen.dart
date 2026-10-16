import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/capsule_button.dart';
import '../../../app/widgets/grouped_card.dart';
import '../../../core/storage/app_settings.dart';
import '../data/settings_data_providers.dart';
import '../domain/account.dart';
import 'settings_messages.dart';

const Map<String, String> _languageNames = <String, String>{
  'uz': 'O‘zbekcha',
  'ru': 'Русский',
  'en': 'English',
};

/// Account and assistant settings (SOW 06 §3, 09): profile, language, the
/// confirmation setting (kept on the server, AC-APP-4), devices, signing out
/// and deleting the account.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Profile? _profile;
  List<Device> _devices = const <Device>[];
  Object? _loadError;
  bool _busy = false;
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  AccountRepository get _account => ref.read(accountRepositoryProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final AccountRepository account = _account;
    try {
      final Profile profile = await account.profile();
      final List<Device> devices = await account.devices();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _devices = devices;
        _loadError = null;
      });
      await _cache(profile);
    } on Object catch (error) {
      if (mounted) setState(() => _loadError = error);
    }
  }

  /// The server is the source of truth; the phone keeps a copy for offline starts.
  Future<void> _cache(Profile profile) => ref
      .read(appSettingsProvider.notifier)
      .update(
        (AppSettings settings) => settings.copyWith(
          confirmSensitiveActions: profile.confirmSensitiveActions,
          language: profile.language,
        ),
      );

  Future<void> _act(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on Object catch (error) {
      if (mounted) _say(settingsFailureMessage(context.l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _update({
    String? displayName,
    String? language,
    bool? confirmSensitiveActions,
  }) {
    final AccountRepository account = _account;
    return _act(() async {
      final Profile profile = await account.update(
        displayName: displayName,
        language: language,
        confirmSensitiveActions: confirmSensitiveActions,
      );
      if (!mounted) return;
      setState(() => _profile = profile);
      await _cache(profile);
    });
  }

  Future<void> _editName() async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initial: _profile?.displayName ?? ''),
    );
    if (name != null && name.isNotEmpty) await _update(displayName: name);
  }

  Future<void> _pickLanguage() async {
    final String? language = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final MapEntry<String, String> entry in _languageNames.entries)
              ListTile(
                key: Key('settings-language-${entry.key}'),
                title: Text(entry.value),
                trailing: entry.key == _profile?.language
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(sheet).pop(entry.key),
              ),
          ],
        ),
      ),
    );
    if (language != null && language != _profile?.language) {
      await _update(language: language);
    }
  }

  Future<void> _removeDevice(Device device) {
    final AccountRepository account = _account;
    return _act(() async {
      await account.removeDevice(device.id);
      if (mounted) {
        setState(
          () => _devices = <Device>[
            for (final Device d in _devices)
              if (d.id != device.id) d,
          ],
        );
      }
    });
  }

  Future<void> _resend() {
    final AccountRepository account = _account;
    final String sent = context.l10n.settingsEmailSent;
    return _act(() async {
      await account.resendVerification();
      if (mounted) _say(sent);
    });
  }

  Future<void> _delete() async {
    final AppLocalizations l10n = context.l10n;
    final bool? sure = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialog) => AlertDialog(
        title: Text(l10n.settingsDeleteTitle),
        content: Text(l10n.settingsDeleteBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            key: const Key('settings-delete-confirm'),
            style: TextButton.styleFrom(foregroundColor: AlesleColors.danger),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.settingsDeleteConfirm),
          ),
        ],
      ),
    );
    if (sure != true) return;
    final AccountRepository account = _account;
    await _act(() async {
      await account.requestDeletion();
      await _load();
      // The notice with "cancel" is at the top.
      if (_scroll.hasClients) {
        await _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _cancelDeletion() {
    final AccountRepository account = _account;
    return _act(() async {
      final Profile profile = await account.cancelDeletion();
      if (mounted) setState(() => _profile = profile);
    });
  }

  String _date(DateTime value) =>
      MaterialLocalizations.of(context).formatMediumDate(value.toLocal());

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    final Profile? profile = _profile;
    final bool voiceReplies = ref.watch(
      appSettingsProvider.select((AppSettings s) => s.voiceReplies),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: profile == null
          ? Center(
              child: _loadError == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          settingsFailureMessage(l10n, _loadError!),
                          key: const Key('settings-load-error'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          key: const Key('settings-retry'),
                          onPressed: () {
                            setState(() => _loadError = null);
                            unawaited(_load());
                          },
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
            )
          : ListView(
              controller: _scroll,
              // Clear of the gesture bar at the end of the list.
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                32 + MediaQuery.paddingOf(context).bottom,
              ),
              children: <Widget>[
                if (profile.deletionScheduledAt case final DateTime at)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AlesleCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              l10n.settingsDeletionScheduled(_date(at)),
                              key: const Key('settings-deletion-scheduled'),
                              style: text.bodyLarge,
                            ),
                            const SizedBox(height: 12),
                            CapsuleButton(
                              key: const Key('settings-cancel-deletion'),
                              label: l10n.settingsCancelDeletion,
                              onPressed: _busy ? null : _cancelDeletion,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                _Header(l10n.settingsAccount),
                AlesleGroup(
                  children: <Widget>[
                    ListTile(
                      key: const Key('settings-name'),
                      title: Text(l10n.settingsName),
                      subtitle: Text(
                        profile.displayName ?? l10n.settingsNameEmpty,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _busy ? null : _editName,
                    ),
                    ListTile(
                      key: const Key('settings-email'),
                      title: Text(profile.email),
                      subtitle: profile.emailVerified
                          ? null
                          : Text(
                              l10n.settingsEmailUnverified,
                              style: const TextStyle(
                                color: AlesleColors.danger,
                              ),
                            ),
                      trailing: profile.emailVerified
                          ? const Icon(
                              Icons.verified_rounded,
                              color: AlesleColors.violet,
                            )
                          : null,
                    ),
                    if (!profile.emailVerified)
                      ListTile(
                        key: const Key('settings-resend'),
                        leading: const Icon(Icons.mark_email_unread_outlined),
                        title: Text(l10n.settingsResendEmail),
                        onTap: _busy ? null : _resend,
                      ),
                  ],
                ),
                _Header(l10n.settingsAssistant),
                AlesleGroup(
                  children: <Widget>[
                    ListTile(
                      key: const Key('settings-language'),
                      title: Text(l10n.settingsLanguage),
                      subtitle: Text(
                        _languageNames[profile.language] ?? profile.language,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _busy ? null : _pickLanguage,
                    ),
                    SwitchListTile(
                      key: const Key('settings-confirm'),
                      title: Text(l10n.settingsConfirmActions),
                      subtitle: Text(l10n.settingsConfirmActionsHelp),
                      value: profile.confirmSensitiveActions,
                      onChanged: _busy
                          ? null
                          : (bool value) => unawaited(
                              _update(confirmSensitiveActions: value),
                            ),
                    ),
                    SwitchListTile(
                      key: const Key('settings-voice'),
                      title: Text(l10n.settingsVoiceReplies),
                      value: voiceReplies,
                      onChanged: (bool value) => unawaited(
                        ref
                            .read(appSettingsProvider.notifier)
                            .update(
                              (AppSettings s) =>
                                  s.copyWith(voiceReplies: value),
                            ),
                      ),
                    ),
                  ],
                ),
                _Header(l10n.settingsDevices),
                AlesleGroup(
                  children: <Widget>[
                    for (final Device device in _devices)
                      ListTile(
                        key: Key('settings-device-${device.id}'),
                        leading: const Icon(Icons.smartphone_rounded),
                        title: Text(device.name ?? l10n.settingsUnknownDevice),
                        subtitle: Text(
                          device.current
                              ? l10n.settingsThisDevice
                              : l10n.settingsLastUsed(_date(device.lastUsedAt)),
                        ),
                        trailing: device.current
                            ? null
                            : TextButton(
                                key: Key('settings-remove-${device.id}'),
                                onPressed: _busy
                                    ? null
                                    : () => unawaited(_removeDevice(device)),
                                child: Text(l10n.settingsRemoveDevice),
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                CapsuleButton(
                  key: const Key('settings-sign-out'),
                  label: l10n.settingsSignOut,
                  style: CapsuleStyle.secondary,
                  onPressed: _busy
                      ? null
                      : () => unawaited(_act(_account.signOut)),
                ),
                const SizedBox(height: 8),
                CapsuleButton(
                  key: const Key('settings-sign-out-everywhere'),
                  label: l10n.settingsSignOutEverywhere,
                  style: CapsuleStyle.secondary,
                  onPressed: _busy
                      ? null
                      : () => unawaited(_act(_account.signOutEverywhere)),
                ),
                if (profile.deletionScheduledAt == null) ...<Widget>[
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('settings-delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: AlesleColors.danger,
                    ),
                    onPressed: _busy ? null : _delete,
                    child: Text(l10n.settingsDeleteAccount),
                  ),
                ],
              ],
            ),
    );
  }
}

/// Owns its text controller: the dialog's closing animation still reads it
/// after the result is back.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _field = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.settingsName),
      content: TextField(
        key: const Key('settings-name-field'),
        controller: _field,
        autofocus: true,
        maxLength: 80,
        textCapitalization: TextCapitalization.words,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          key: const Key('settings-name-save'),
          onPressed: () => Navigator.of(context).pop(_field.text.trim()),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: AlesleColors.text2),
      ),
    );
  }
}
