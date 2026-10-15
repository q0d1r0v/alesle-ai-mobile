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

  @override
  String get greetingMorning => 'Xayrli tong';

  @override
  String get greetingDay => 'Xayrli kun';

  @override
  String get greetingEvening => 'Xayrli kech';

  @override
  String get homeTapToType => 'Bosing va yozing';

  @override
  String get homeExample => 'Masalan: “Onamga qo‘ng‘iroq qil”';

  @override
  String get commandHint => 'Nima qilay?';

  @override
  String get commandSend => 'Yuborish';

  @override
  String get taskWorking => 'Bajaryapman…';

  @override
  String get taskStop => 'To‘xtatish';

  @override
  String get taskDoneButton => 'Tayyor';

  @override
  String get taskDoneTitle => 'Bajarildi';

  @override
  String get taskNotDoneTitle => 'Bajarib bo‘lmadi';

  @override
  String get taskStoppedTitle => 'To‘xtatildi';

  @override
  String get taskYouSaid => 'Siz aytdingiz';

  @override
  String get reasonGeneric => 'Nimadir xato ketdi. Qaytadan urinib ko‘ring.';

  @override
  String get reasonStuck => 'Ekranda kerakli joyni topa olmadim.';

  @override
  String get reasonTimeout => 'Juda uzoq davom etdi, to‘xtatdim.';

  @override
  String get reasonConnection => 'Internet aloqasi uzildi.';

  @override
  String get reasonServer => 'Serverga ulana olmadim.';

  @override
  String get reasonAi =>
      'AI xizmati hozir ishlamayapti. Birozdan keyin urinib ko‘ring.';

  @override
  String get reasonSteps => 'Juda ko‘p qadam kerak bo‘ldi, to‘xtatdim.';

  @override
  String get reasonNotSignedIn => 'Avval tizimga kiring.';

  @override
  String get reasonAlreadyRunning => 'Bitta vazifa allaqachon bajarilmoqda.';

  @override
  String get turnOnTitle => 'Alesle’ni yoqing';

  @override
  String get turnOnBody =>
      'Bitta tugma — va Alesle siz uchun bosadi va yozadi.';

  @override
  String get turnOnButton => 'Sozlamalarni ochish';
}
