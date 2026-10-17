import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In uz, this message translates to:
  /// **'Alesle AI'**
  String get appTitle;

  /// No description provided for @serverStatusTitle.
  ///
  /// In uz, this message translates to:
  /// **'Server'**
  String get serverStatusTitle;

  /// No description provided for @serverReady.
  ///
  /// In uz, this message translates to:
  /// **'Ishlayapti'**
  String get serverReady;

  /// No description provided for @serverChecking.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirilmoqda…'**
  String get serverChecking;

  /// No description provided for @serverUnavailable.
  ///
  /// In uz, this message translates to:
  /// **'Server bilan aloqa yo\'q'**
  String get serverUnavailable;

  /// No description provided for @errorNetwork.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasini tekshiring'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In uz, this message translates to:
  /// **'Serverda xatolik ({code})'**
  String errorServer(String code);

  /// No description provided for @errorUnexpected.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmagan xatolik'**
  String get errorUnexpected;

  /// No description provided for @retry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get retry;

  /// No description provided for @agentStatusTitle.
  ///
  /// In uz, this message translates to:
  /// **'Agent ruxsati'**
  String get agentStatusTitle;

  /// No description provided for @accessibilityEnabled.
  ///
  /// In uz, this message translates to:
  /// **'Maxsus imkoniyatlar yoqilgan'**
  String get accessibilityEnabled;

  /// No description provided for @accessibilityDisabled.
  ///
  /// In uz, this message translates to:
  /// **'Agent ishlashi uchun \"Maxsus imkoniyatlar\"da Alesle AI ni yoqing'**
  String get accessibilityDisabled;

  /// No description provided for @enableAccessibility.
  ///
  /// In uz, this message translates to:
  /// **'Yoqish'**
  String get enableAccessibility;

  /// No description provided for @policyConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Har bir muhim amal sizning tasdig\'ingiz bilan bajariladi'**
  String get policyConfirm;

  /// No description provided for @policyCountdown.
  ///
  /// In uz, this message translates to:
  /// **'Muhim amallar 3 soniyalik ortga sanashdan keyin bajariladi, uni bekor qilsa bo\'ladi'**
  String get policyCountdown;

  /// No description provided for @greetingMorning.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli tong'**
  String get greetingMorning;

  /// No description provided for @greetingDay.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli kun'**
  String get greetingDay;

  /// No description provided for @greetingEvening.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli kech'**
  String get greetingEvening;

  /// No description provided for @homeTapToType.
  ///
  /// In uz, this message translates to:
  /// **'Bosing va yozing'**
  String get homeTapToType;

  /// No description provided for @homeExample.
  ///
  /// In uz, this message translates to:
  /// **'Masalan: “Onamga qo‘ng‘iroq qil”'**
  String get homeExample;

  /// No description provided for @commandHint.
  ///
  /// In uz, this message translates to:
  /// **'Nima qilay?'**
  String get commandHint;

  /// No description provided for @commandSend.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get commandSend;

  /// No description provided for @taskWorking.
  ///
  /// In uz, this message translates to:
  /// **'Bajaryapman…'**
  String get taskWorking;

  /// No description provided for @taskStop.
  ///
  /// In uz, this message translates to:
  /// **'To‘xtatish'**
  String get taskStop;

  /// No description provided for @taskDoneButton.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get taskDoneButton;

  /// No description provided for @taskDoneTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bajarildi'**
  String get taskDoneTitle;

  /// No description provided for @taskNotDoneTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bajarib bo‘lmadi'**
  String get taskNotDoneTitle;

  /// No description provided for @taskStoppedTitle.
  ///
  /// In uz, this message translates to:
  /// **'To‘xtatildi'**
  String get taskStoppedTitle;

  /// No description provided for @taskYouSaid.
  ///
  /// In uz, this message translates to:
  /// **'Siz aytdingiz'**
  String get taskYouSaid;

  /// No description provided for @reasonGeneric.
  ///
  /// In uz, this message translates to:
  /// **'Nimadir xato ketdi. Qaytadan urinib ko‘ring.'**
  String get reasonGeneric;

  /// No description provided for @reasonStuck.
  ///
  /// In uz, this message translates to:
  /// **'Ekranda kerakli joyni topa olmadim.'**
  String get reasonStuck;

  /// No description provided for @reasonTimeout.
  ///
  /// In uz, this message translates to:
  /// **'Juda uzoq davom etdi, to‘xtatdim.'**
  String get reasonTimeout;

  /// No description provided for @reasonConnection.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi uzildi.'**
  String get reasonConnection;

  /// No description provided for @reasonServer.
  ///
  /// In uz, this message translates to:
  /// **'Serverga ulana olmadim.'**
  String get reasonServer;

  /// No description provided for @reasonAi.
  ///
  /// In uz, this message translates to:
  /// **'AI xizmati hozir ishlamayapti. Birozdan keyin urinib ko‘ring.'**
  String get reasonAi;

  /// No description provided for @reasonSteps.
  ///
  /// In uz, this message translates to:
  /// **'Juda ko‘p qadam kerak bo‘ldi, to‘xtatdim.'**
  String get reasonSteps;

  /// No description provided for @reasonNotSignedIn.
  ///
  /// In uz, this message translates to:
  /// **'Avval tizimga kiring.'**
  String get reasonNotSignedIn;

  /// No description provided for @reasonAlreadyRunning.
  ///
  /// In uz, this message translates to:
  /// **'Bitta vazifa allaqachon bajarilmoqda.'**
  String get reasonAlreadyRunning;

  /// No description provided for @turnOnTitle.
  ///
  /// In uz, this message translates to:
  /// **'Alesle’ni yoqing'**
  String get turnOnTitle;

  /// No description provided for @turnOnBody.
  ///
  /// In uz, this message translates to:
  /// **'Bitta tugma — va Alesle siz uchun bosadi va yozadi.'**
  String get turnOnBody;

  /// No description provided for @turnOnButton.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalarni ochish'**
  String get turnOnButton;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Telefoningizga nima qilishni ayting'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In uz, this message translates to:
  /// **'Alesle uni siz uchun bajaradi.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In uz, this message translates to:
  /// **'Boshlash'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingContinue.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get onboardingContinue;

  /// No description provided for @onboardingLater.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq'**
  String get onboardingLater;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tilingiz'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageBody.
  ///
  /// In uz, this message translates to:
  /// **'Alesle ham shu tilda gapiradi.'**
  String get onboardingLanguageBody;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Alesle qanday ishlaydi'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyPoint1.
  ///
  /// In uz, this message translates to:
  /// **'Vazifangiz davomida ekranni o‘qiydi va siz uchun bosadi.'**
  String get onboardingPrivacyPoint1;

  /// No description provided for @onboardingPrivacyPoint2.
  ///
  /// In uz, this message translates to:
  /// **'Ekran rasmlari va mazmuni saqlanmaydi.'**
  String get onboardingPrivacyPoint2;

  /// No description provided for @onboardingPrivacyPoint3.
  ///
  /// In uz, this message translates to:
  /// **'Muhim amaldan oldin so‘raydi; istalgan payt to‘xtatish mumkin.'**
  String get onboardingPrivacyPoint3;

  /// No description provided for @onboardingPermissionsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Uchta tez ruxsat'**
  String get onboardingPermissionsTitle;

  /// No description provided for @onboardingPermissionsBody.
  ///
  /// In uz, this message translates to:
  /// **'Telefon so‘raydi — har safar «Ruxsat berish»ni bosing.'**
  String get onboardingPermissionsBody;

  /// No description provided for @permissionMicrophone.
  ///
  /// In uz, this message translates to:
  /// **'Mikrofon'**
  String get permissionMicrophone;

  /// No description provided for @permissionMicrophoneWhy.
  ///
  /// In uz, this message translates to:
  /// **'sizni eshitish uchun'**
  String get permissionMicrophoneWhy;

  /// No description provided for @permissionContacts.
  ///
  /// In uz, this message translates to:
  /// **'Kontaktlar'**
  String get permissionContacts;

  /// No description provided for @permissionContactsWhy.
  ///
  /// In uz, this message translates to:
  /// **'kerakli odamni topish uchun'**
  String get permissionContactsWhy;

  /// No description provided for @permissionNotifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get permissionNotifications;

  /// No description provided for @permissionNotificationsWhy.
  ///
  /// In uz, this message translates to:
  /// **'To‘xtatish tugmasini ko‘rsatish uchun'**
  String get permissionNotificationsWhy;

  /// No description provided for @permissionAllow.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berish'**
  String get permissionAllow;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalarda yoqish'**
  String get permissionOpenSettings;

  /// No description provided for @turnOnGreyHelp.
  ///
  /// In uz, this message translates to:
  /// **'Tugma kulrangmi? Ko‘rsataman'**
  String get turnOnGreyHelp;

  /// No description provided for @restrictedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Cheklangan sozlamalarga ruxsat bering'**
  String get restrictedTitle;

  /// No description provided for @restrictedStep1.
  ///
  /// In uz, this message translates to:
  /// **'«Ilova haqida»ni oching'**
  String get restrictedStep1;

  /// No description provided for @restrictedStep2.
  ///
  /// In uz, this message translates to:
  /// **'Yuqoridagi ⋮ menyusini bosing'**
  String get restrictedStep2;

  /// No description provided for @restrictedStep3.
  ///
  /// In uz, this message translates to:
  /// **'«Cheklangan sozlamalarga ruxsat»ni tanlang'**
  String get restrictedStep3;

  /// No description provided for @restrictedStep4.
  ///
  /// In uz, this message translates to:
  /// **'Qaytib, Alesle’ni yoqing'**
  String get restrictedStep4;

  /// No description provided for @restrictedOpen.
  ///
  /// In uz, this message translates to:
  /// **'Ilova haqida'**
  String get restrictedOpen;

  /// No description provided for @onboardingBatteryTitle.
  ///
  /// In uz, this message translates to:
  /// **'Alesle to‘xtab qolmasin'**
  String get onboardingBatteryTitle;

  /// No description provided for @onboardingBatteryBody.
  ///
  /// In uz, this message translates to:
  /// **'Telefon batareyani tejash uchun Alesle’ni to‘xtatib qo‘yishi mumkin. Unga ishlashga ruxsat bering.'**
  String get onboardingBatteryBody;

  /// No description provided for @onboardingBatteryButton.
  ///
  /// In uz, this message translates to:
  /// **'Batareya cheklovini olib tashlash'**
  String get onboardingBatteryButton;

  /// No description provided for @onboardingAutostartButton.
  ///
  /// In uz, this message translates to:
  /// **'Avtoishga tushirishni yoqish'**
  String get onboardingAutostartButton;

  /// No description provided for @onboardingDoneTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi tayyor'**
  String get onboardingDoneTitle;

  /// No description provided for @onboardingDoneBody.
  ///
  /// In uz, this message translates to:
  /// **'Doirani bosing va gapiring.'**
  String get onboardingDoneBody;

  /// No description provided for @onboardingDoneButton.
  ///
  /// In uz, this message translates to:
  /// **'Boshladik'**
  String get onboardingDoneButton;

  /// No description provided for @offTitle.
  ///
  /// In uz, this message translates to:
  /// **'Alesle o‘chiq'**
  String get offTitle;

  /// No description provided for @offBody.
  ///
  /// In uz, this message translates to:
  /// **'Telefon uni o‘chirib qo‘ydi. Davom etish uchun qayta yoqing.'**
  String get offBody;

  /// No description provided for @offButton.
  ///
  /// In uz, this message translates to:
  /// **'Yoqish'**
  String get offButton;

  /// No description provided for @homeTapToSpeak.
  ///
  /// In uz, this message translates to:
  /// **'Bosing va gapiring'**
  String get homeTapToSpeak;

  /// No description provided for @homeListening.
  ///
  /// In uz, this message translates to:
  /// **'Eshityapman'**
  String get homeListening;

  /// No description provided for @homeTapToStop.
  ///
  /// In uz, this message translates to:
  /// **'Tugatish uchun bosing'**
  String get homeTapToStop;

  /// No description provided for @homeUnderstanding.
  ///
  /// In uz, this message translates to:
  /// **'Tushunyapman…'**
  String get homeUnderstanding;

  /// No description provided for @homeTypeInstead.
  ///
  /// In uz, this message translates to:
  /// **'Yozib yuborish'**
  String get homeTypeInstead;

  /// No description provided for @voiceNotHeard.
  ///
  /// In uz, this message translates to:
  /// **'Eshitmadim. Yana bir bor ayting.'**
  String get voiceNotHeard;

  /// No description provided for @voiceUnavailable.
  ///
  /// In uz, this message translates to:
  /// **'Ovoz xizmati hozir ishlamayapti. Yozib yuboring.'**
  String get voiceUnavailable;

  /// No description provided for @voiceMicDenied.
  ///
  /// In uz, this message translates to:
  /// **'Mikrofonga ruxsat kerak.'**
  String get voiceMicDenied;

  /// No description provided for @handsFreeLabel.
  ///
  /// In uz, this message translates to:
  /// **'Doim tinglash'**
  String get handsFreeLabel;

  /// No description provided for @handsFreeListening.
  ///
  /// In uz, this message translates to:
  /// **'Tinglayapman — shunchaki gapiring'**
  String get handsFreeListening;

  /// No description provided for @handsFreeMuted.
  ///
  /// In uz, this message translates to:
  /// **'Mikrofon o‘chiq'**
  String get handsFreeMuted;

  /// No description provided for @handsFreeUnderstanding.
  ///
  /// In uz, this message translates to:
  /// **'Tushunyapman…'**
  String get handsFreeUnderstanding;

  /// No description provided for @handsFreeMute.
  ///
  /// In uz, this message translates to:
  /// **'Ovozsiz qilish'**
  String get handsFreeMute;

  /// No description provided for @handsFreeUnmute.
  ///
  /// In uz, this message translates to:
  /// **'Tinglashni yoqish'**
  String get handsFreeUnmute;

  /// No description provided for @handsFreeHeard.
  ///
  /// In uz, this message translates to:
  /// **'«{text}»'**
  String handsFreeHeard(String text);

  /// No description provided for @handsFreeWhileRunning.
  ///
  /// In uz, this message translates to:
  /// **'Gapiring: vazifaga qo‘shing, o‘zgartiring yoki «to‘xta» deng'**
  String get handsFreeWhileRunning;

  /// No description provided for @handsFreeStartFailed.
  ///
  /// In uz, this message translates to:
  /// **'Mikrofonni yoqib bo‘lmadi. Ilovani ochiq holda qayta urining.'**
  String get handsFreeStartFailed;

  /// No description provided for @liveTitle.
  ///
  /// In uz, this message translates to:
  /// **'Live'**
  String get liveTitle;

  /// No description provided for @liveConnecting.
  ///
  /// In uz, this message translates to:
  /// **'Ulanyapman…'**
  String get liveConnecting;

  /// No description provided for @liveListening.
  ///
  /// In uz, this message translates to:
  /// **'Tinglayapman'**
  String get liveListening;

  /// No description provided for @liveHearing.
  ///
  /// In uz, this message translates to:
  /// **'Eshityapman…'**
  String get liveHearing;

  /// No description provided for @liveThinking.
  ///
  /// In uz, this message translates to:
  /// **'O‘ylayapman…'**
  String get liveThinking;

  /// No description provided for @liveSpeaking.
  ///
  /// In uz, this message translates to:
  /// **'Gapiryapman'**
  String get liveSpeaking;

  /// No description provided for @liveMuted.
  ///
  /// In uz, this message translates to:
  /// **'Mikrofon o‘chiq'**
  String get liveMuted;

  /// No description provided for @liveHint.
  ///
  /// In uz, this message translates to:
  /// **'Gapiring — men shu yerdaman'**
  String get liveHint;

  /// No description provided for @liveKeyboard.
  ///
  /// In uz, this message translates to:
  /// **'Yozish'**
  String get liveKeyboard;

  /// No description provided for @liveClose.
  ///
  /// In uz, this message translates to:
  /// **'Tugatish'**
  String get liveClose;

  /// No description provided for @liveTaskRunning.
  ///
  /// In uz, this message translates to:
  /// **'Bajaryapman: {task}'**
  String liveTaskRunning(String task);

  /// No description provided for @liveTaskStop.
  ///
  /// In uz, this message translates to:
  /// **'Vazifani to‘xtatish'**
  String get liveTaskStop;

  /// No description provided for @signInTitle.
  ///
  /// In uz, this message translates to:
  /// **'Alesle’ga kiring'**
  String get signInTitle;

  /// No description provided for @signInBody.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar va tarixingiz barcha qurilmalarda saqlanadi.'**
  String get signInBody;

  /// No description provided for @signInGoogle.
  ///
  /// In uz, this message translates to:
  /// **'Google bilan davom etish'**
  String get signInGoogle;

  /// No description provided for @signInEmail.
  ///
  /// In uz, this message translates to:
  /// **'Email bilan davom etish'**
  String get signInEmail;

  /// No description provided for @signInEmailLabel.
  ///
  /// In uz, this message translates to:
  /// **'Email'**
  String get signInEmailLabel;

  /// No description provided for @signInPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get signInPasswordLabel;

  /// No description provided for @signInNameLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ismingiz (ixtiyoriy)'**
  String get signInNameLabel;

  /// No description provided for @signInButton.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get signInButton;

  /// No description provided for @signInCreateButton.
  ///
  /// In uz, this message translates to:
  /// **'Akkaunt yaratish'**
  String get signInCreateButton;

  /// No description provided for @signInToCreate.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntingiz yo‘qmi? Yarating'**
  String get signInToCreate;

  /// No description provided for @signInToSignIn.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntingiz bormi? Kiring'**
  String get signInToSignIn;

  /// No description provided for @signInSendLink.
  ///
  /// In uz, this message translates to:
  /// **'Parolsiz: emailga havola yuboring'**
  String get signInSendLink;

  /// No description provided for @signInLinkSentTitle.
  ///
  /// In uz, this message translates to:
  /// **'Emailingizni tekshiring'**
  String get signInLinkSentTitle;

  /// No description provided for @signInLinkSentBody.
  ///
  /// In uz, this message translates to:
  /// **'{email} manziliga kirish havolasini yubordik. Uni shu telefonda oching.'**
  String signInLinkSentBody(String email);

  /// No description provided for @signInBackToOptions.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa usul'**
  String get signInBackToOptions;

  /// No description provided for @signInSigningIn.
  ///
  /// In uz, this message translates to:
  /// **'Kirilmoqda…'**
  String get signInSigningIn;

  /// No description provided for @signInBadEmail.
  ///
  /// In uz, this message translates to:
  /// **'Email manzilini tekshiring.'**
  String get signInBadEmail;

  /// No description provided for @signInShortPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parol kamida 8 belgi bo‘lsin.'**
  String get signInShortPassword;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In uz, this message translates to:
  /// **'Email yoki parol noto‘g‘ri.'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailTaken.
  ///
  /// In uz, this message translates to:
  /// **'Bu email bilan akkaunt bor. Kiring yoki havola so‘rang.'**
  String get authEmailTaken;

  /// No description provided for @authLinkInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Havola eskirgan yoki ishlatilgan. Yangisini so‘rang.'**
  String get authLinkInvalid;

  /// No description provided for @authGoogleFailed.
  ///
  /// In uz, this message translates to:
  /// **'Google bilan kirib bo‘lmadi. Boshqa usulni sinang.'**
  String get authGoogleFailed;

  /// No description provided for @authSessionExpired.
  ///
  /// In uz, this message translates to:
  /// **'Qaytadan kiring.'**
  String get authSessionExpired;

  /// No description provided for @authTooMany.
  ///
  /// In uz, this message translates to:
  /// **'Juda ko‘p urinish. Bir daqiqadan keyin qayta urining.'**
  String get authTooMany;

  /// No description provided for @emailVerified.
  ///
  /// In uz, this message translates to:
  /// **'Email tasdiqlandi.'**
  String get emailVerified;

  /// No description provided for @settingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In uz, this message translates to:
  /// **'Akkaunt'**
  String get settingsAccount;

  /// No description provided for @settingsName.
  ///
  /// In uz, this message translates to:
  /// **'Ism'**
  String get settingsName;

  /// No description provided for @settingsNameEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Kiritilmagan'**
  String get settingsNameEmpty;

  /// No description provided for @settingsEmailUnverified.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlanmagan'**
  String get settingsEmailUnverified;

  /// No description provided for @settingsResendEmail.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash xatini qayta yuborish'**
  String get settingsResendEmail;

  /// No description provided for @settingsEmailSent.
  ///
  /// In uz, this message translates to:
  /// **'Xat yuborildi.'**
  String get settingsEmailSent;

  /// No description provided for @settingsAssistant.
  ///
  /// In uz, this message translates to:
  /// **'Yordamchi'**
  String get settingsAssistant;

  /// No description provided for @settingsLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get settingsLanguage;

  /// No description provided for @settingsConfirmActions.
  ///
  /// In uz, this message translates to:
  /// **'Har muhim amalni tasdiqlash'**
  String get settingsConfirmActions;

  /// No description provided for @settingsConfirmActionsHelp.
  ///
  /// In uz, this message translates to:
  /// **'O‘chirilsa — 3 soniyalik bekor qilish imkoniyati. To‘lov va o‘chirish har doim tasdiqlanadi.'**
  String get settingsConfirmActionsHelp;

  /// No description provided for @settingsVoiceReplies.
  ///
  /// In uz, this message translates to:
  /// **'Javoblarni ovozda o‘qish'**
  String get settingsVoiceReplies;

  /// No description provided for @settingsDevices.
  ///
  /// In uz, this message translates to:
  /// **'Qurilmalar'**
  String get settingsDevices;

  /// No description provided for @settingsThisDevice.
  ///
  /// In uz, this message translates to:
  /// **'Shu qurilma'**
  String get settingsThisDevice;

  /// No description provided for @settingsUnknownDevice.
  ///
  /// In uz, this message translates to:
  /// **'Noma’lum qurilma'**
  String get settingsUnknownDevice;

  /// No description provided for @settingsLastUsed.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi marta: {date}'**
  String settingsLastUsed(String date);

  /// No description provided for @settingsRemoveDevice.
  ///
  /// In uz, this message translates to:
  /// **'Chiqarish'**
  String get settingsRemoveDevice;

  /// No description provided for @settingsSignOut.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutEverywhere.
  ///
  /// In uz, this message translates to:
  /// **'Hamma qurilmalardan chiqish'**
  String get settingsSignOutEverywhere;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntni o‘chirish'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Akkaunt o‘chirilsinmi?'**
  String get settingsDeleteTitle;

  /// No description provided for @settingsDeleteBody.
  ///
  /// In uz, this message translates to:
  /// **'Ma’lumotlaringiz 7 kundan keyin butunlay o‘chiriladi. Shu muddat ichida bekor qilishingiz mumkin.'**
  String get settingsDeleteBody;

  /// No description provided for @settingsDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'O‘chirish'**
  String get settingsDeleteConfirm;

  /// No description provided for @settingsDeletionScheduled.
  ///
  /// In uz, this message translates to:
  /// **'Akkaunt {date} kuni o‘chiriladi.'**
  String settingsDeletionScheduled(String date);

  /// No description provided for @settingsCancelDeletion.
  ///
  /// In uz, this message translates to:
  /// **'O‘chirishni bekor qilish'**
  String get settingsCancelDeletion;

  /// No description provided for @commonCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get commonSave;

  /// No description provided for @commonRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get commonRetry;

  /// No description provided for @memoryTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xotira'**
  String get memoryTitle;

  /// No description provided for @memoryBody.
  ///
  /// In uz, this message translates to:
  /// **'Alesle buyruqlarni qisqartirish uchun eslab qolgan narsalar. Xabarlaringiz matni saqlanmaydi.'**
  String get memoryBody;

  /// No description provided for @memoryEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha hech narsa eslab qolinmagan. «Eslab qol: …» deb ayting.'**
  String get memoryEmpty;

  /// No description provided for @memoryKindPreference.
  ///
  /// In uz, this message translates to:
  /// **'Afzallik'**
  String get memoryKindPreference;

  /// No description provided for @memoryKindContact.
  ///
  /// In uz, this message translates to:
  /// **'Kontakt'**
  String get memoryKindContact;

  /// No description provided for @memoryKindFact.
  ///
  /// In uz, this message translates to:
  /// **'Fakt'**
  String get memoryKindFact;

  /// No description provided for @memoryKindEpisode.
  ///
  /// In uz, this message translates to:
  /// **'Voqea'**
  String get memoryKindEpisode;

  /// No description provided for @memoryForget.
  ///
  /// In uz, this message translates to:
  /// **'Unutish'**
  String get memoryForget;

  /// No description provided for @memoryForgetAll.
  ///
  /// In uz, this message translates to:
  /// **'Hammasini unutish'**
  String get memoryForgetAll;

  /// No description provided for @memoryForgetAllTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi unutilsinmi?'**
  String get memoryForgetAllTitle;

  /// No description provided for @memoryForgetAllBody.
  ///
  /// In uz, this message translates to:
  /// **'Alesle siz haqingizda eslab qolgan hamma narsani o‘chiradi. Buni qaytarib bo‘lmaydi.'**
  String get memoryForgetAllBody;

  /// No description provided for @memoryForgotten.
  ///
  /// In uz, this message translates to:
  /// **'Unutildi.'**
  String get memoryForgotten;

  /// No description provided for @historyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tarix'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali vazifalar yo‘q.'**
  String get historyEmpty;

  /// No description provided for @historyClear.
  ///
  /// In uz, this message translates to:
  /// **'Tarixni tozalash'**
  String get historyClear;

  /// No description provided for @historyClearTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tarix tozalansinmi?'**
  String get historyClearTitle;

  /// No description provided for @historyClearBody.
  ///
  /// In uz, this message translates to:
  /// **'Barcha o‘tgan vazifalar va ularning matni o‘chiriladi.'**
  String get historyClearBody;

  /// No description provided for @historyDelete.
  ///
  /// In uz, this message translates to:
  /// **'O‘chirish'**
  String get historyDelete;

  /// No description provided for @historyLoadMore.
  ///
  /// In uz, this message translates to:
  /// **'Yana ko‘rsatish'**
  String get historyLoadMore;

  /// No description provided for @historyStatusDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarildi'**
  String get historyStatusDone;

  /// No description provided for @historyStatusFailed.
  ///
  /// In uz, this message translates to:
  /// **'Bo‘lmadi'**
  String get historyStatusFailed;

  /// No description provided for @historyStatusCannot.
  ///
  /// In uz, this message translates to:
  /// **'Imkonsiz'**
  String get historyStatusCannot;

  /// No description provided for @historyStatusStopped.
  ///
  /// In uz, this message translates to:
  /// **'To‘xtatildi'**
  String get historyStatusStopped;

  /// No description provided for @historyStatusInterrupted.
  ///
  /// In uz, this message translates to:
  /// **'Uzildi'**
  String get historyStatusInterrupted;

  /// No description provided for @settingsMemory.
  ///
  /// In uz, this message translates to:
  /// **'Xotira'**
  String get settingsMemory;

  /// No description provided for @settingsHistory.
  ///
  /// In uz, this message translates to:
  /// **'Tarix'**
  String get settingsHistory;

  /// No description provided for @settingsPlan.
  ///
  /// In uz, this message translates to:
  /// **'Tarif va limit'**
  String get settingsPlan;

  /// No description provided for @billingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tarif'**
  String get billingTitle;

  /// No description provided for @billingPlanFree.
  ///
  /// In uz, this message translates to:
  /// **'Bepul'**
  String get billingPlanFree;

  /// No description provided for @billingUsed.
  ///
  /// In uz, this message translates to:
  /// **'Bu oy {percent}% ishlatildi'**
  String billingUsed(Object percent);

  /// No description provided for @billingResets.
  ///
  /// In uz, this message translates to:
  /// **'Limit yangilanadi: {date}'**
  String billingResets(Object date);

  /// No description provided for @billingSimpleMode.
  ///
  /// In uz, this message translates to:
  /// **'Limit tugadi: faqat oddiy buyruqlar (qo‘ng‘iroq, budilnik, SMS) ishlaydi.'**
  String get billingSimpleMode;

  /// No description provided for @billingPaidUntil.
  ///
  /// In uz, this message translates to:
  /// **'{date} gacha to‘langan'**
  String billingPaidUntil(Object date);

  /// No description provided for @billingEndsOn.
  ///
  /// In uz, this message translates to:
  /// **'{date} da tugaydi, uzaytirilmaydi'**
  String billingEndsOn(Object date);

  /// No description provided for @billingPastDue.
  ///
  /// In uz, this message translates to:
  /// **'Obunani uzaytirib bo‘lmadi, bepul tarifdasiz.'**
  String get billingPastDue;

  /// No description provided for @billingCancel.
  ///
  /// In uz, this message translates to:
  /// **'Uzaytirishni to‘xtatish'**
  String get billingCancel;

  /// No description provided for @billingResume.
  ///
  /// In uz, this message translates to:
  /// **'Uzaytirishni yoqish'**
  String get billingResume;

  /// No description provided for @billingCancelTitle.
  ///
  /// In uz, this message translates to:
  /// **'Uzaytirish to‘xtatilsinmi?'**
  String get billingCancelTitle;

  /// No description provided for @billingCancelBody.
  ///
  /// In uz, this message translates to:
  /// **'Tarif {date} gacha ishlaydi, keyin bepul tarifga o‘tasiz.'**
  String billingCancelBody(Object date);

  /// No description provided for @billingPlans.
  ///
  /// In uz, this message translates to:
  /// **'Tariflar'**
  String get billingPlans;

  /// No description provided for @billingPerMonth.
  ///
  /// In uz, this message translates to:
  /// **'{price} so‘m / oy'**
  String billingPerMonth(Object price);

  /// No description provided for @billingPrice.
  ///
  /// In uz, this message translates to:
  /// **'{price} so‘m'**
  String billingPrice(Object price);

  /// No description provided for @billingFeatureDaily.
  ///
  /// In uz, this message translates to:
  /// **'Kuniga {commands} ta buyruq'**
  String billingFeatureDaily(Object commands);

  /// No description provided for @billingFeatureScreenDaily.
  ///
  /// In uz, this message translates to:
  /// **'Kuniga {tasks} ta ilova vazifasi'**
  String billingFeatureScreenDaily(Object tasks);

  /// No description provided for @billingFeatureNoDaily.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik cheklovsiz'**
  String get billingFeatureNoDaily;

  /// No description provided for @billingFeatureVision.
  ///
  /// In uz, this message translates to:
  /// **'Ekrandagi rasmlarni ham tushunadi'**
  String get billingFeatureVision;

  /// No description provided for @billingFeatureStrong.
  ///
  /// In uz, this message translates to:
  /// **'Murakkab vazifalar uchun eng kuchli model'**
  String get billingFeatureStrong;

  /// No description provided for @billingCurrent.
  ///
  /// In uz, this message translates to:
  /// **'Joriy tarif'**
  String get billingCurrent;

  /// No description provided for @billingChoose.
  ///
  /// In uz, this message translates to:
  /// **'Tanlash'**
  String get billingChoose;

  /// No description provided for @billingExtend.
  ///
  /// In uz, this message translates to:
  /// **'Uzaytirish'**
  String get billingExtend;

  /// No description provided for @billingPackTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shimcha limit'**
  String get billingPackTitle;

  /// No description provided for @billingPackBody.
  ///
  /// In uz, this message translates to:
  /// **'Shu oy uchun ko‘proq ish. Tarif o‘zgarmaydi.'**
  String get billingPackBody;

  /// No description provided for @billingAddMore.
  ///
  /// In uz, this message translates to:
  /// **'Ko‘proq qo‘shish · {price} so‘m'**
  String billingAddMore(Object price);

  /// No description provided for @billingPayTitle.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov usuli'**
  String get billingPayTitle;

  /// No description provided for @billingMethodCard.
  ///
  /// In uz, this message translates to:
  /// **'Bank kartasi'**
  String get billingMethodCard;

  /// No description provided for @billingSecure.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsiz. Alesle karta ma’lumotlaringizni ko‘rmaydi.'**
  String get billingSecure;

  /// No description provided for @billingNoMethods.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov hozircha mavjud emas. Keyinroq urinib ko‘ring.'**
  String get billingNoMethods;

  /// No description provided for @billingPageNotOpened.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov sahifasini ochib bo‘lmadi.'**
  String get billingPageNotOpened;

  /// No description provided for @billingChecking.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov tekshirilmoqda…'**
  String get billingChecking;

  /// No description provided for @billingCheckingBody.
  ///
  /// In uz, this message translates to:
  /// **'Odatda bir necha soniya oladi.'**
  String get billingCheckingBody;

  /// No description provided for @billingPaid.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov qabul qilindi'**
  String get billingPaid;

  /// No description provided for @billingPaidBody.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi tayyor, davom etavering.'**
  String get billingPaidBody;

  /// No description provided for @billingNotPaid.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov o‘tmadi'**
  String get billingNotPaid;

  /// No description provided for @billingNotPaidBody.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yoki boshqa usul bilan urinib ko‘ring.'**
  String get billingNotPaidBody;

  /// No description provided for @billingStillWaiting.
  ///
  /// In uz, this message translates to:
  /// **'Hali tasdiqlanmadi'**
  String get billingStillWaiting;

  /// No description provided for @billingStillWaitingBody.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov tasdiqlanishi bilan tarif o‘zi yoqiladi.'**
  String get billingStillWaitingBody;

  /// No description provided for @billingCheckAgain.
  ///
  /// In uz, this message translates to:
  /// **'Yana tekshirish'**
  String get billingCheckAgain;

  /// No description provided for @limitMonthTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bu oylik limit tugadi'**
  String get limitMonthTitle;

  /// No description provided for @limitMonthBody.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘ng‘iroq, budilnik va SMS ishlayveradi. Ilovalar bilan ishlash uchun ko‘proq qo‘shing.'**
  String get limitMonthBody;

  /// No description provided for @limitDailyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi bepul limit tugadi'**
  String get limitDailyTitle;

  /// No description provided for @limitDailyBody.
  ///
  /// In uz, this message translates to:
  /// **'Ertaga yana davom etasiz yoki Pro bilan kunlik cheklovsiz ishlaysiz.'**
  String get limitDailyBody;

  /// No description provided for @limitUpgrade.
  ///
  /// In uz, this message translates to:
  /// **'Tarifni oshirish'**
  String get limitUpgrade;

  /// No description provided for @limitWaitUntil.
  ///
  /// In uz, this message translates to:
  /// **'{date} gacha kutish'**
  String limitWaitUntil(Object date);

  /// No description provided for @limitWaitTomorrow.
  ///
  /// In uz, this message translates to:
  /// **'Ertagacha kutish'**
  String get limitWaitTomorrow;

  /// No description provided for @usageHighNotice.
  ///
  /// In uz, this message translates to:
  /// **'Bu oylik limitning {percent}% ishlatildi.'**
  String usageHighNotice(Object percent);

  /// No description provided for @taskAddMore.
  ///
  /// In uz, this message translates to:
  /// **'Ko‘proq qo‘shish'**
  String get taskAddMore;

  /// No description provided for @commonLater.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq'**
  String get commonLater;

  /// No description provided for @commonDone.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get commonDone;

  /// No description provided for @updateTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangilanish'**
  String get updateTitle;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi versiya chiqdi'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In uz, this message translates to:
  /// **'Bir daqiqacha vaqt oladi.'**
  String get updateAvailableBody;

  /// No description provided for @updateRequiredBody.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish uchun ilovani yangilang. Bir daqiqacha vaqt oladi.'**
  String get updateRequiredBody;

  /// No description provided for @updateNow.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get updateNow;

  /// No description provided for @updateUpToDate.
  ///
  /// In uz, this message translates to:
  /// **'Eng so‘nggi versiya o‘rnatilgan'**
  String get updateUpToDate;

  /// No description provided for @updateVersion.
  ///
  /// In uz, this message translates to:
  /// **'Versiya {version}'**
  String updateVersion(Object version);

  /// No description provided for @updateNewVersion.
  ///
  /// In uz, this message translates to:
  /// **'Yangi versiya: {version}'**
  String updateNewVersion(Object version);

  /// No description provided for @updateDownloading.
  ///
  /// In uz, this message translates to:
  /// **'Yuklanmoqda… {percent}%'**
  String updateDownloading(Object percent);

  /// No description provided for @updateInstalling.
  ///
  /// In uz, this message translates to:
  /// **'O‘rnatilmoqda…'**
  String get updateInstalling;

  /// No description provided for @updatePermissionNeeded.
  ///
  /// In uz, this message translates to:
  /// **'Alesle’ga ilova o‘rnatishga ruxsat bering, so‘ng qaytib «Yangilash»ni bosing.'**
  String get updatePermissionNeeded;

  /// No description provided for @updateRejected.
  ///
  /// In uz, this message translates to:
  /// **'Fayl tekshiruvdan o‘tmadi va o‘rnatilmadi. Ilovani alesle.ai saytidan yuklab oling.'**
  String get updateRejected;

  /// No description provided for @updateFailed.
  ///
  /// In uz, this message translates to:
  /// **'Yangilab bo‘lmadi. Qayta urinib ko‘ring.'**
  String get updateFailed;

  /// No description provided for @updateStarted.
  ///
  /// In uz, this message translates to:
  /// **'O‘rnatishni tasdiqlang.'**
  String get updateStarted;

  /// No description provided for @settingsUpdate.
  ///
  /// In uz, this message translates to:
  /// **'Yangilanish'**
  String get settingsUpdate;

  /// No description provided for @settingsLegal.
  ///
  /// In uz, this message translates to:
  /// **'Huquqiy ma’lumot'**
  String get settingsLegal;

  /// No description provided for @settingsPrivacy.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosati'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanish shartlari'**
  String get settingsTerms;

  /// No description provided for @settingsRefund.
  ///
  /// In uz, this message translates to:
  /// **'Pulni qaytarish'**
  String get settingsRefund;

  /// No description provided for @settingsSupport.
  ///
  /// In uz, this message translates to:
  /// **'Yordam'**
  String get settingsSupport;

  /// No description provided for @settingsLinkFailed.
  ///
  /// In uz, this message translates to:
  /// **'Sahifani ochib bo‘lmadi.'**
  String get settingsLinkFailed;

  /// No description provided for @reasonUpgrade.
  ///
  /// In uz, this message translates to:
  /// **'Ilovaning bu versiyasi eskirgan. Uni yangilang.'**
  String get reasonUpgrade;

  /// No description provided for @settingsDeleteGuide.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntni o‘chirish haqida'**
  String get settingsDeleteGuide;

  /// No description provided for @linkAlreadySignedIn.
  ///
  /// In uz, this message translates to:
  /// **'Siz allaqachon akkauntga kirgansiz. Boshqa akkauntga o‘tish uchun avval chiqing.'**
  String get linkAlreadySignedIn;

  /// No description provided for @linkVerifySignInFirst.
  ///
  /// In uz, this message translates to:
  /// **'Emailni tasdiqlash uchun avval shu akkauntga kiring, so‘ng havolani qayta oching.'**
  String get linkVerifySignInFirst;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
