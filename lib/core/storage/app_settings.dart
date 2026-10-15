import 'package:shared_preferences/shared_preferences.dart';

/// The user's choices kept on this phone. Until accounts exist (Sprint 5)
/// they live only here; then the confirmation setting moves to the profile.
final class AppSettings {
  const AppSettings({
    this.onboardingDone = false,
    this.language,
    this.voiceReplies = true,
    this.confirmSensitiveActions = true,
  });

  final bool onboardingDone;

  /// en, uz or ru; null follows the phone's language.
  final String? language;

  /// Read the agent's replies aloud (SOW 04 §4.1, "silent mode" when off).
  final bool voiceReplies;

  /// "Confirm every sensitive action": on by default (A4, D11).
  final bool confirmSensitiveActions;

  AppSettings copyWith({
    bool? onboardingDone,
    String? language,
    bool clearLanguage = false,
    bool? voiceReplies,
    bool? confirmSensitiveActions,
  }) => AppSettings(
    onboardingDone: onboardingDone ?? this.onboardingDone,
    language: clearLanguage ? null : (language ?? this.language),
    voiceReplies: voiceReplies ?? this.voiceReplies,
    confirmSensitiveActions:
        confirmSensitiveActions ?? this.confirmSensitiveActions,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.onboardingDone == onboardingDone &&
      other.language == language &&
      other.voiceReplies == voiceReplies &&
      other.confirmSensitiveActions == confirmSensitiveActions;

  @override
  int get hashCode => Object.hash(
    onboardingDone,
    language,
    voiceReplies,
    confirmSensitiveActions,
  );
}

/// [AppSettings] in SharedPreferences. Reads are synchronous after [load].
final class AppSettingsStore {
  AppSettingsStore(this._prefs);

  static const String _onboarding = 'onboarding_done';
  static const String _language = 'language';
  static const String _voice = 'voice_replies';
  static const String _confirm = 'confirm_sensitive_actions';

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
  }
}
