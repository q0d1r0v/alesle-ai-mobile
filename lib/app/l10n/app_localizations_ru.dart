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
}
