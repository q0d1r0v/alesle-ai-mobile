// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Alesle AI';

  @override
  String get serverStatusTitle => 'Server';

  @override
  String get serverReady => 'Ishlayapti';

  @override
  String get serverChecking => 'Tekshirilmoqda…';

  @override
  String get serverUnavailable => 'Server bilan aloqa yo\'q';

  @override
  String get errorNetwork => 'Internet aloqasini tekshiring';

  @override
  String errorServer(String code) {
    return 'Serverda xatolik ($code)';
  }

  @override
  String get errorUnexpected => 'Kutilmagan xatolik';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get agentStatusTitle => 'Agent ruxsati';

  @override
  String get accessibilityEnabled => 'Maxsus imkoniyatlar yoqilgan';

  @override
  String get accessibilityDisabled =>
      'Agent ishlashi uchun \"Maxsus imkoniyatlar\"da Alesle AI ni yoqing';

  @override
  String get enableAccessibility => 'Yoqish';

  @override
  String get policyConfirm =>
      'Har bir muhim amal sizning tasdig\'ingiz bilan bajariladi';

  @override
  String get policyCountdown =>
      'Muhim amallar 3 soniyalik ortga sanashdan keyin bajariladi, uni bekor qilsa bo\'ladi';
}
