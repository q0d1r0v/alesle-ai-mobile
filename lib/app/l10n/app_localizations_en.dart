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
  String get policyCountdown =>
      'Important actions run after a 3-second countdown you can cancel';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingDay => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get homeTapToType => 'Tap and type';

  @override
  String get homeExample => 'Try “Call Mom”';

  @override
  String get commandHint => 'What should I do?';

  @override
  String get commandSend => 'Send';

  @override
  String get taskWorking => 'Working on it…';

  @override
  String get taskStop => 'Stop';

  @override
  String get taskDoneButton => 'Done';

  @override
  String get taskDoneTitle => 'All done';

  @override
  String get taskNotDoneTitle => 'Not done';

  @override
  String get taskStoppedTitle => 'Stopped';

  @override
  String get taskYouSaid => 'You said';

  @override
  String get reasonGeneric => 'Something went wrong. Please try again.';

  @override
  String get reasonStuck => 'I couldn\'t find my way on the screen.';

  @override
  String get reasonTimeout => 'It took too long, so I stopped.';

  @override
  String get reasonConnection => 'The connection dropped.';

  @override
  String get reasonServer => 'I couldn\'t reach the server.';

  @override
  String get reasonAi =>
      'The AI service is unavailable right now. Try again soon.';

  @override
  String get reasonSteps => 'It needed too many steps, so I stopped.';

  @override
  String get reasonNotSignedIn => 'Please sign in first.';

  @override
  String get reasonAlreadyRunning => 'A task is already running.';

  @override
  String get turnOnTitle => 'Turn on Alesle';

  @override
  String get turnOnBody => 'One switch lets it tap and type for you.';

  @override
  String get turnOnButton => 'Open settings';
}
