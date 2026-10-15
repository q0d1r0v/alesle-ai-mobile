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
