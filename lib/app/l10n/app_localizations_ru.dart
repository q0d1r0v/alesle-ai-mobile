// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Alesle AI';

  @override
  String get serverStatusTitle => 'Сервер';

  @override
  String get serverReady => 'Работает';

  @override
  String get serverChecking => 'Проверка…';

  @override
  String get serverUnavailable => 'Нет связи с сервером';

  @override
  String get errorNetwork => 'Проверьте подключение к интернету';

  @override
  String errorServer(String code) {
    return 'Ошибка сервера ($code)';
  }

  @override
  String get errorUnexpected => 'Непредвиденная ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get agentStatusTitle => 'Доступ агента';

  @override
  String get accessibilityEnabled => 'Специальные возможности включены';

  @override
  String get accessibilityDisabled =>
      'Чтобы агент работал, включите Alesle AI в «Специальных возможностях»';

  @override
  String get enableAccessibility => 'Включить';

  @override
  String get policyConfirm =>
      'Каждое важное действие выполняется с вашего подтверждения';

  @override
  String get policyCountdown =>
      'Важные действия выполняются после 3-секундного отсчёта, его можно отменить';

  @override
  String get greetingMorning => 'Доброе утро';

  @override
  String get greetingDay => 'Добрый день';

  @override
  String get greetingEvening => 'Добрый вечер';

  @override
  String get homeTapToType => 'Нажмите и напишите';

  @override
  String get homeExample => 'Например: «Позвони маме»';

  @override
  String get commandHint => 'Что сделать?';

  @override
  String get commandSend => 'Отправить';

  @override
  String get taskWorking => 'Выполняю…';

  @override
  String get taskStop => 'Остановить';

  @override
  String get taskDoneButton => 'Готово';

  @override
  String get taskDoneTitle => 'Сделано';

  @override
  String get taskNotDoneTitle => 'Не получилось';

  @override
  String get taskStoppedTitle => 'Остановлено';

  @override
  String get taskYouSaid => 'Вы сказали';

  @override
  String get reasonGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get reasonStuck => 'Не нашёл нужное на экране.';

  @override
  String get reasonTimeout => 'Слишком долго, я остановился.';

  @override
  String get reasonConnection => 'Связь прервалась.';

  @override
  String get reasonServer => 'Не удалось подключиться к серверу.';

  @override
  String get reasonAi => 'Сервис ИИ сейчас недоступен. Попробуйте позже.';

  @override
  String get reasonSteps => 'Понадобилось слишком много шагов, я остановился.';

  @override
  String get reasonNotSignedIn => 'Сначала войдите.';

  @override
  String get reasonAlreadyRunning => 'Одна задача уже выполняется.';

  @override
  String get turnOnTitle => 'Включите Alesle';

  @override
  String get turnOnBody =>
      'Один переключатель — и Alesle будет нажимать и печатать за вас.';

  @override
  String get turnOnButton => 'Открыть настройки';

  @override
  String get onboardingWelcomeTitle => 'Скажите телефону, что сделать';

  @override
  String get onboardingWelcomeBody => 'Alesle сделает это за вас.';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get onboardingLater => 'Позже';

  @override
  String get onboardingLanguageTitle => 'Ваш язык';

  @override
  String get onboardingLanguageBody => 'Alesle будет говорить на нём.';

  @override
  String get onboardingPrivacyTitle => 'Как работает Alesle';

  @override
  String get onboardingPrivacyPoint1 =>
      'Во время задачи читает экран и нажимает за вас.';

  @override
  String get onboardingPrivacyPoint2 =>
      'Снимки и содержимое экрана не сохраняются.';

  @override
  String get onboardingPrivacyPoint3 =>
      'Перед важными действиями спрашивает; остановить можно в любой момент.';

  @override
  String get onboardingPermissionsTitle => 'Три быстрых «да»';

  @override
  String get onboardingPermissionsBody =>
      'Телефон спросит — каждый раз нажмите «Разрешить».';

  @override
  String get permissionMicrophone => 'Микрофон';

  @override
  String get permissionMicrophoneWhy => 'чтобы слышать вас';

  @override
  String get permissionContacts => 'Контакты';

  @override
  String get permissionContactsWhy => 'чтобы найти нужного человека';

  @override
  String get permissionNotifications => 'Уведомления';

  @override
  String get permissionNotificationsWhy => 'чтобы показать кнопку «Стоп»';

  @override
  String get permissionAllow => 'Разрешить';

  @override
  String get permissionOpenSettings => 'Включить в настройках';

  @override
  String get turnOnGreyHelp => 'Переключатель серый? Покажу как';

  @override
  String get restrictedTitle => 'Разрешите ограниченные настройки';

  @override
  String get restrictedStep1 => 'Откройте «О приложении»';

  @override
  String get restrictedStep2 => 'Нажмите ⋮ в правом верхнем углу';

  @override
  String get restrictedStep3 => 'Выберите «Разрешить ограниченные настройки»';

  @override
  String get restrictedStep4 => 'Вернитесь и включите Alesle';

  @override
  String get restrictedOpen => 'О приложении';

  @override
  String get onboardingBatteryTitle => 'Чтобы Alesle не останавливался';

  @override
  String get onboardingBatteryBody =>
      'Телефон может останавливать Alesle ради батареи. Разрешите ему работать.';

  @override
  String get onboardingBatteryButton => 'Снять ограничение батареи';

  @override
  String get onboardingAutostartButton => 'Включить автозапуск';

  @override
  String get onboardingDoneTitle => 'Всё готово';

  @override
  String get onboardingDoneBody => 'Нажмите на круг и говорите.';

  @override
  String get onboardingDoneButton => 'Начнём';

  @override
  String get offTitle => 'Alesle выключен';

  @override
  String get offBody =>
      'Телефон выключил его. Включите снова, чтобы продолжить.';

  @override
  String get offButton => 'Включить';

  @override
  String get homeTapToSpeak => 'Нажмите и говорите';

  @override
  String get homeListening => 'Слушаю';

  @override
  String get homeTapToStop => 'Нажмите, чтобы закончить';

  @override
  String get homeUnderstanding => 'Распознаю…';

  @override
  String get homeTypeInstead => 'Написать текстом';

  @override
  String get voiceNotHeard => 'Не расслышал. Скажите ещё раз.';

  @override
  String get voiceUnavailable =>
      'Голосовой сервис недоступен. Напишите текстом.';

  @override
  String get voiceMicDenied => 'Нужен доступ к микрофону.';

  @override
  String get signInTitle => 'Войдите в Alesle';

  @override
  String get signInBody =>
      'Настройки и история сохранятся на всех устройствах.';

  @override
  String get signInGoogle => 'Продолжить с Google';

  @override
  String get signInEmail => 'Продолжить с email';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Пароль';

  @override
  String get signInNameLabel => 'Ваше имя (необязательно)';

  @override
  String get signInButton => 'Войти';

  @override
  String get signInCreateButton => 'Создать аккаунт';

  @override
  String get signInToCreate => 'Нет аккаунта? Создайте';

  @override
  String get signInToSignIn => 'Уже есть аккаунт? Войдите';

  @override
  String get signInSendLink => 'Без пароля: пришлите ссылку на email';

  @override
  String get signInLinkSentTitle => 'Проверьте почту';

  @override
  String signInLinkSentBody(String email) {
    return 'Мы отправили ссылку для входа на $email. Откройте её на этом телефоне.';
  }

  @override
  String get signInBackToOptions => 'Другой способ';

  @override
  String get signInSigningIn => 'Входим…';

  @override
  String get signInBadEmail => 'Проверьте email.';

  @override
  String get signInShortPassword => 'Пароль — минимум 8 символов.';

  @override
  String get authInvalidCredentials => 'Неверный email или пароль.';

  @override
  String get authEmailTaken =>
      'Аккаунт с этим email уже есть. Войдите или запросите ссылку.';

  @override
  String get authLinkInvalid =>
      'Ссылка устарела или уже использована. Запросите новую.';

  @override
  String get authGoogleFailed =>
      'Не удалось войти через Google. Попробуйте другой способ.';

  @override
  String get authSessionExpired => 'Войдите снова.';

  @override
  String get authTooMany => 'Слишком много попыток. Попробуйте через минуту.';

  @override
  String get emailVerified => 'Email подтверждён.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get settingsName => 'Имя';

  @override
  String get settingsNameEmpty => 'Не указано';

  @override
  String get settingsEmailUnverified => 'Не подтверждён';

  @override
  String get settingsResendEmail => 'Отправить письмо ещё раз';

  @override
  String get settingsEmailSent => 'Письмо отправлено.';

  @override
  String get settingsAssistant => 'Ассистент';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsConfirmActions => 'Подтверждать каждое важное действие';

  @override
  String get settingsConfirmActionsHelp =>
      'Если выключено — 3 секунды на отмену. Оплата и удаление подтверждаются всегда.';

  @override
  String get settingsVoiceReplies => 'Читать ответы вслух';

  @override
  String get settingsDevices => 'Устройства';

  @override
  String get settingsThisDevice => 'Это устройство';

  @override
  String get settingsUnknownDevice => 'Неизвестное устройство';

  @override
  String settingsLastUsed(String date) {
    return 'Последний раз: $date';
  }

  @override
  String get settingsRemoveDevice => 'Выйти';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get settingsSignOutEverywhere => 'Выйти на всех устройствах';

  @override
  String get settingsDeleteAccount => 'Удалить аккаунт';

  @override
  String get settingsDeleteTitle => 'Удалить аккаунт?';

  @override
  String get settingsDeleteBody =>
      'Данные удалятся навсегда через 7 дней. До этого можно отменить.';

  @override
  String get settingsDeleteConfirm => 'Удалить';

  @override
  String settingsDeletionScheduled(String date) {
    return 'Аккаунт будет удалён $date.';
  }

  @override
  String get settingsCancelDeletion => 'Отменить удаление';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonRetry => 'Повторить';
}
