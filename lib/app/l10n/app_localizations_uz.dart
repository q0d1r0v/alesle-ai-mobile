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

  @override
  String get onboardingWelcomeTitle => 'Telefoningizga nima qilishni ayting';

  @override
  String get onboardingWelcomeBody => 'Alesle uni siz uchun bajaradi.';

  @override
  String get onboardingGetStarted => 'Boshlash';

  @override
  String get onboardingContinue => 'Davom etish';

  @override
  String get onboardingLater => 'Keyinroq';

  @override
  String get onboardingLanguageTitle => 'Tilingiz';

  @override
  String get onboardingLanguageBody => 'Alesle ham shu tilda gapiradi.';

  @override
  String get onboardingPrivacyTitle => 'Alesle qanday ishlaydi';

  @override
  String get onboardingPrivacyPoint1 =>
      'Vazifangiz davomida ekranni o‘qiydi va siz uchun bosadi.';

  @override
  String get onboardingPrivacyPoint2 =>
      'Ekran rasmlari va mazmuni saqlanmaydi.';

  @override
  String get onboardingPrivacyPoint3 =>
      'Muhim amaldan oldin so‘raydi; istalgan payt to‘xtatish mumkin.';

  @override
  String get onboardingPermissionsTitle => 'Uchta tez ruxsat';

  @override
  String get onboardingPermissionsBody =>
      'Telefon so‘raydi — har safar «Ruxsat berish»ni bosing.';

  @override
  String get permissionMicrophone => 'Mikrofon';

  @override
  String get permissionMicrophoneWhy => 'sizni eshitish uchun';

  @override
  String get permissionContacts => 'Kontaktlar';

  @override
  String get permissionContactsWhy => 'kerakli odamni topish uchun';

  @override
  String get permissionNotifications => 'Bildirishnomalar';

  @override
  String get permissionNotificationsWhy =>
      'To‘xtatish tugmasini ko‘rsatish uchun';

  @override
  String get permissionAllow => 'Ruxsat berish';

  @override
  String get permissionOpenSettings => 'Sozlamalarda yoqish';

  @override
  String get turnOnGreyHelp => 'Tugma kulrangmi? Ko‘rsataman';

  @override
  String get restrictedTitle => 'Cheklangan sozlamalarga ruxsat bering';

  @override
  String get restrictedStep1 => '«Ilova haqida»ni oching';

  @override
  String get restrictedStep2 => 'Yuqoridagi ⋮ menyusini bosing';

  @override
  String get restrictedStep3 => '«Cheklangan sozlamalarga ruxsat»ni tanlang';

  @override
  String get restrictedStep4 => 'Qaytib, Alesle’ni yoqing';

  @override
  String get restrictedOpen => 'Ilova haqida';

  @override
  String get onboardingBatteryTitle => 'Alesle to‘xtab qolmasin';

  @override
  String get onboardingBatteryBody =>
      'Telefon batareyani tejash uchun Alesle’ni to‘xtatib qo‘yishi mumkin. Unga ishlashga ruxsat bering.';

  @override
  String get onboardingBatteryButton => 'Batareya cheklovini olib tashlash';

  @override
  String get onboardingAutostartButton => 'Avtoishga tushirishni yoqish';

  @override
  String get onboardingDoneTitle => 'Hammasi tayyor';

  @override
  String get onboardingDoneBody => 'Doirani bosing va gapiring.';

  @override
  String get onboardingDoneButton => 'Boshladik';

  @override
  String get offTitle => 'Alesle o‘chiq';

  @override
  String get offBody =>
      'Telefon uni o‘chirib qo‘ydi. Davom etish uchun qayta yoqing.';

  @override
  String get offButton => 'Yoqish';

  @override
  String get homeTapToSpeak => 'Bosing va gapiring';

  @override
  String get homeListening => 'Eshityapman';

  @override
  String get homeTapToStop => 'Tugatish uchun bosing';

  @override
  String get homeUnderstanding => 'Tushunyapman…';

  @override
  String get homeTypeInstead => 'Yozib yuborish';

  @override
  String get voiceNotHeard => 'Eshitmadim. Yana bir bor ayting.';

  @override
  String get voiceUnavailable =>
      'Ovoz xizmati hozir ishlamayapti. Yozib yuboring.';

  @override
  String get voiceMicDenied => 'Mikrofonga ruxsat kerak.';

  @override
  String get signInTitle => 'Alesle’ga kiring';

  @override
  String get signInBody =>
      'Sozlamalar va tarixingiz barcha qurilmalarda saqlanadi.';

  @override
  String get signInGoogle => 'Google bilan davom etish';

  @override
  String get signInEmail => 'Email bilan davom etish';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Parol';

  @override
  String get signInNameLabel => 'Ismingiz (ixtiyoriy)';

  @override
  String get signInButton => 'Kirish';

  @override
  String get signInCreateButton => 'Akkaunt yaratish';

  @override
  String get signInToCreate => 'Akkauntingiz yo‘qmi? Yarating';

  @override
  String get signInToSignIn => 'Akkauntingiz bormi? Kiring';

  @override
  String get signInSendLink => 'Parolsiz: emailga havola yuboring';

  @override
  String get signInLinkSentTitle => 'Emailingizni tekshiring';

  @override
  String signInLinkSentBody(String email) {
    return '$email manziliga kirish havolasini yubordik. Uni shu telefonda oching.';
  }

  @override
  String get signInBackToOptions => 'Boshqa usul';

  @override
  String get signInSigningIn => 'Kirilmoqda…';

  @override
  String get signInBadEmail => 'Email manzilini tekshiring.';

  @override
  String get signInShortPassword => 'Parol kamida 8 belgi bo‘lsin.';

  @override
  String get authInvalidCredentials => 'Email yoki parol noto‘g‘ri.';

  @override
  String get authEmailTaken =>
      'Bu email bilan akkaunt bor. Kiring yoki havola so‘rang.';

  @override
  String get authLinkInvalid =>
      'Havola eskirgan yoki ishlatilgan. Yangisini so‘rang.';

  @override
  String get authGoogleFailed =>
      'Google bilan kirib bo‘lmadi. Boshqa usulni sinang.';

  @override
  String get authSessionExpired => 'Qaytadan kiring.';

  @override
  String get authTooMany =>
      'Juda ko‘p urinish. Bir daqiqadan keyin qayta urining.';

  @override
  String get emailVerified => 'Email tasdiqlandi.';

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String get settingsAccount => 'Akkaunt';

  @override
  String get settingsName => 'Ism';

  @override
  String get settingsNameEmpty => 'Kiritilmagan';

  @override
  String get settingsEmailUnverified => 'Tasdiqlanmagan';

  @override
  String get settingsResendEmail => 'Tasdiqlash xatini qayta yuborish';

  @override
  String get settingsEmailSent => 'Xat yuborildi.';

  @override
  String get settingsAssistant => 'Yordamchi';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get settingsConfirmActions => 'Har muhim amalni tasdiqlash';

  @override
  String get settingsConfirmActionsHelp =>
      'O‘chirilsa — 3 soniyalik bekor qilish imkoniyati. To‘lov va o‘chirish har doim tasdiqlanadi.';

  @override
  String get settingsVoiceReplies => 'Javoblarni ovozda o‘qish';

  @override
  String get settingsDevices => 'Qurilmalar';

  @override
  String get settingsThisDevice => 'Shu qurilma';

  @override
  String get settingsUnknownDevice => 'Noma’lum qurilma';

  @override
  String settingsLastUsed(String date) {
    return 'Oxirgi marta: $date';
  }

  @override
  String get settingsRemoveDevice => 'Chiqarish';

  @override
  String get settingsSignOut => 'Chiqish';

  @override
  String get settingsSignOutEverywhere => 'Hamma qurilmalardan chiqish';

  @override
  String get settingsDeleteAccount => 'Akkauntni o‘chirish';

  @override
  String get settingsDeleteTitle => 'Akkaunt o‘chirilsinmi?';

  @override
  String get settingsDeleteBody =>
      'Ma’lumotlaringiz 7 kundan keyin butunlay o‘chiriladi. Shu muddat ichida bekor qilishingiz mumkin.';

  @override
  String get settingsDeleteConfirm => 'O‘chirish';

  @override
  String settingsDeletionScheduled(String date) {
    return 'Akkaunt $date kuni o‘chiriladi.';
  }

  @override
  String get settingsCancelDeletion => 'O‘chirishni bekor qilish';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonSave => 'Saqlash';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get memoryTitle => 'Xotira';

  @override
  String get memoryBody =>
      'Alesle buyruqlarni qisqartirish uchun eslab qolgan narsalar. Xabarlaringiz matni saqlanmaydi.';

  @override
  String get memoryEmpty =>
      'Hozircha hech narsa eslab qolinmagan. «Eslab qol: …» deb ayting.';

  @override
  String get memoryKindPreference => 'Afzallik';

  @override
  String get memoryKindContact => 'Kontakt';

  @override
  String get memoryKindFact => 'Fakt';

  @override
  String get memoryKindEpisode => 'Voqea';

  @override
  String get memoryForget => 'Unutish';

  @override
  String get memoryForgetAll => 'Hammasini unutish';

  @override
  String get memoryForgetAllTitle => 'Hammasi unutilsinmi?';

  @override
  String get memoryForgetAllBody =>
      'Alesle siz haqingizda eslab qolgan hamma narsani o‘chiradi. Buni qaytarib bo‘lmaydi.';

  @override
  String get memoryForgotten => 'Unutildi.';

  @override
  String get historyTitle => 'Tarix';

  @override
  String get historyEmpty => 'Hali vazifalar yo‘q.';

  @override
  String get historyClear => 'Tarixni tozalash';

  @override
  String get historyClearTitle => 'Tarix tozalansinmi?';

  @override
  String get historyClearBody =>
      'Barcha o‘tgan vazifalar va ularning matni o‘chiriladi.';

  @override
  String get historyDelete => 'O‘chirish';

  @override
  String get historyLoadMore => 'Yana ko‘rsatish';

  @override
  String get historyStatusDone => 'Bajarildi';

  @override
  String get historyStatusFailed => 'Bo‘lmadi';

  @override
  String get historyStatusCannot => 'Imkonsiz';

  @override
  String get historyStatusStopped => 'To‘xtatildi';

  @override
  String get historyStatusInterrupted => 'Uzildi';

  @override
  String get settingsMemory => 'Xotira';

  @override
  String get settingsHistory => 'Tarix';
}
