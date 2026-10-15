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
  String get policyAutonomous => 'Агент выполняет задачи самостоятельно';
}
