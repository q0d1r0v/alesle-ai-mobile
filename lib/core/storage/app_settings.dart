import 'package:shared_preferences/shared_preferences.dart';

/// The user's choices kept on this phone. Until accounts exist (Sprint 5)
/// they live only here; then the confirmation setting moves to the profile.
final class AppSettings {
  const AppSettings({
    this.onboardingDone = false,
    this.language,
    this.voiceReplies = true,
    this.confirmSensitiveActions = true,
    this.usageNoticeKey,
    this.offeredUpdate,
    this.handsFree,
  });

  final bool onboardingDone;

  /// en, uz or ru; null follows the phone's language.
  final String? language;

  /// Read the agent's replies aloud (SOW 04 §4.1, "silent mode" when off).
  final bool voiceReplies;

  /// "Confirm every sensitive action": on by default (A4, D11).
  final bool confirmSensitiveActions;

  /// The last usage notice shown (80 % or used up), so each shows once per
  /// period.
  final String? usageNoticeKey;

  /// The newest version code the "new version" sheet was shown for: each
  /// release is offered once (Settings › Updates always shows it).
  final int? offeredUpdate;

  /// Hands-free: listen all the time (mute in the app or the notification),
  /// no button to press (SOW 04 §4.3). Null = never chosen, which is on;
  /// false once the user turns it off.
  final bool? handsFree;

  AppSettings copyWith({
    bool? onboardingDone,
    String? language,
    bool clearLanguage = false,
    bool? voiceReplies,
    bool? confirmSensitiveActions,
    String? usageNoticeKey,
    int? offeredUpdate,
    bool? handsFree,
  }) => AppSettings(
    onboardingDone: onboardingDone ?? this.onboardingDone,
    language: clearLanguage ? null : (language ?? this.language),
    voiceReplies: voiceReplies ?? this.voiceReplies,
    confirmSensitiveActions:
        confirmSensitiveActions ?? this.confirmSensitiveActions,
    usageNoticeKey: usageNoticeKey ?? this.usageNoticeKey,
    offeredUpdate: offeredUpdate ?? this.offeredUpdate,
    handsFree: handsFree ?? this.handsFree,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.onboardingDone == onboardingDone &&
      other.language == language &&
      other.voiceReplies == voiceReplies &&
      other.confirmSensitiveActions == confirmSensitiveActions &&
      other.usageNoticeKey == usageNoticeKey &&
      other.offeredUpdate == offeredUpdate &&
      other.handsFree == handsFree;

  @override
  int get hashCode => Object.hash(
    onboardingDone,
    language,
    voiceReplies,
    confirmSensitiveActions,
    usageNoticeKey,
    offeredUpdate,
    handsFree,
  );
}

/// [AppSettings] in SharedPreferences. Reads are synchronous after [load].
final class AppSettingsStore {
  AppSettingsStore(this._prefs);

  static const String _onboarding = 'onboarding_done';
  static const String _language = 'language';
  static const String _voice = 'voice_replies';
  static const String _confirm = 'confirm_sensitive_actions';
  static const String _usageNotice = 'usage_notice_key';
  static const String _offeredUpdate = 'offered_update';
  static const String _handsFree = 'hands_free';

  static const Set<String> languages = <String>{'en', 'uz', 'ru'};

  final SharedPreferences _prefs;

  static Future<AppSettingsStore> load() async =>
      AppSettingsStore(await SharedPreferences.getInstance());

  AppSettings read() {
    final String? language = _prefs.getString(_language);
    return AppSettings(
      onboardingDone: _prefs.getBool(_onboarding) ?? false,
      language: languages.contains(language) ? language : null,
      voiceReplies: _prefs.getBool(_voice) ?? true,
      confirmSensitiveActions: _prefs.getBool(_confirm) ?? true,
      usageNoticeKey: _prefs.getString(_usageNotice),
      offeredUpdate: _prefs.getInt(_offeredUpdate),
      handsFree: _prefs.getBool(_handsFree),
    );
  }

  Future<void> write(AppSettings settings) async {
    await _prefs.setBool(_onboarding, settings.onboardingDone);
    final String? language = settings.language;
    if (language == null) {
      await _prefs.remove(_language);
    } else {
      await _prefs.setString(_language, language);
    }
    await _prefs.setBool(_voice, settings.voiceReplies);
    await _prefs.setBool(_confirm, settings.confirmSensitiveActions);
    final String? notice = settings.usageNoticeKey;
    if (notice == null) {
      await _prefs.remove(_usageNotice);
    } else {
      await _prefs.setString(_usageNotice, notice);
    }
    final bool? handsFree = settings.handsFree;
    if (handsFree == null) {
      await _prefs.remove(_handsFree);
    } else {
      await _prefs.setBool(_handsFree, handsFree);
    }
    final int? offered = settings.offeredUpdate;
    if (offered == null) {
      await _prefs.remove(_offeredUpdate);
    } else {
      await _prefs.setInt(_offeredUpdate, offered);
    }
  }
}
