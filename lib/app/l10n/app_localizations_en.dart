// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Alesle AI';

  @override
  String get serverStatusTitle => 'Server';

  @override
  String get serverReady => 'Online';

  @override
  String get serverChecking => 'Checking…';

  @override
  String get serverUnavailable => 'Can\'t reach the server';

  @override
  String get errorNetwork => 'Check your internet connection';

  @override
  String errorServer(String code) {
    return 'Server error ($code)';
  }

  @override
  String get errorUnexpected => 'Unexpected error';

  @override
  String get retry => 'Retry';

  @override
  String get agentStatusTitle => 'Agent access';

  @override
  String get accessibilityEnabled => 'Accessibility access is on';

  @override
  String get accessibilityDisabled =>
      'Turn on Alesle AI under Accessibility so the agent can work';

  @override
  String get enableAccessibility => 'Turn on';

  @override
  String get policyConfirm =>
      'Every important action waits for your confirmation';

  @override
  String get policyAutonomous => 'The agent completes tasks on its own';
}
