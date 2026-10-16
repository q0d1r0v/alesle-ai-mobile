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

  @override
  String get onboardingWelcomeTitle => 'Tell your phone what to do';

  @override
  String get onboardingWelcomeBody => 'Alesle does it for you.';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingLater => 'Later';

  @override
  String get onboardingLanguageTitle => 'Your language';

  @override
  String get onboardingLanguageBody => 'Alesle will speak it too.';

  @override
  String get onboardingPrivacyTitle => 'How Alesle works';

  @override
  String get onboardingPrivacyPoint1 =>
      'While doing your task it reads the screen and taps for you.';

  @override
  String get onboardingPrivacyPoint2 =>
      'Screenshots and screen contents are never stored.';

  @override
  String get onboardingPrivacyPoint3 =>
      'It asks before anything important, and you can stop it any time.';

  @override
  String get onboardingPermissionsTitle => 'Three quick yeses';

  @override
  String get onboardingPermissionsBody =>
      'Your phone will ask. Tap Allow each time.';

  @override
  String get permissionMicrophone => 'Microphone';

  @override
  String get permissionMicrophoneWhy => 'to hear you';

  @override
  String get permissionContacts => 'Contacts';

  @override
  String get permissionContactsWhy => 'to find the right person';

  @override
  String get permissionNotifications => 'Notifications';

  @override
  String get permissionNotificationsWhy => 'to show a Stop button';

  @override
  String get permissionAllow => 'Allow';

  @override
  String get permissionOpenSettings => 'Turn on in Settings';

  @override
  String get turnOnGreyHelp => 'Switch is grey? Show me how';

  @override
  String get restrictedTitle => 'Allow restricted settings';

  @override
  String get restrictedStep1 => 'Open App info';

  @override
  String get restrictedStep2 => 'Tap ⋮ in the top corner';

  @override
  String get restrictedStep3 => 'Choose “Allow restricted settings”';

  @override
  String get restrictedStep4 => 'Come back and turn on Alesle';

  @override
  String get restrictedOpen => 'Open App info';

  @override
  String get onboardingBatteryTitle => 'Keep Alesle running';

  @override
  String get onboardingBatteryBody =>
      'Your phone may stop Alesle to save battery. Let it keep running.';

  @override
  String get onboardingBatteryButton => 'Remove the battery limit';

  @override
  String get onboardingAutostartButton => 'Turn on autostart';

  @override
  String get onboardingDoneTitle => 'You’re all set';

  @override
  String get onboardingDoneBody => 'Tap the circle and speak.';

  @override
  String get onboardingDoneButton => 'Let’s go';

  @override
  String get offTitle => 'Alesle is off';

  @override
  String get offBody =>
      'Your phone switched it off. Turn it back on to keep going.';

  @override
  String get offButton => 'Turn on';

  @override
  String get homeTapToSpeak => 'Tap and speak';

  @override
  String get homeListening => 'Listening';

  @override
  String get homeTapToStop => 'Tap to finish';

  @override
  String get homeUnderstanding => 'Understanding…';

  @override
  String get homeTypeInstead => 'Type instead';

  @override
  String get voiceNotHeard => 'I didn’t catch that. Please say it again.';

  @override
  String get voiceUnavailable =>
      'Voice is unavailable right now. Please type instead.';

  @override
  String get voiceMicDenied => 'Microphone access is needed.';

  @override
  String get handsFreeLabel => 'Always listen';

  @override
  String get handsFreeListening => 'Listening — just speak';

  @override
  String get handsFreeMuted => 'Microphone off';

  @override
  String get handsFreeUnderstanding => 'Understanding…';

  @override
  String get handsFreeMute => 'Mute';

  @override
  String get handsFreeUnmute => 'Unmute';

  @override
  String handsFreeHeard(String text) {
    return '“$text”';
  }

  @override
  String get handsFreeWhileRunning =>
      'Speak to add to the task, change it, or say “stop”';

  @override
  String get handsFreeStartFailed =>
      'Couldn\'t turn the microphone on. Try again with the app open.';

  @override
  String get signInTitle => 'Sign in to Alesle';

  @override
  String get signInBody =>
      'Your settings and history stay with you on every device.';

  @override
  String get signInGoogle => 'Continue with Google';

  @override
  String get signInEmail => 'Continue with email';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Password';

  @override
  String get signInNameLabel => 'Your name (optional)';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signInCreateButton => 'Create account';

  @override
  String get signInToCreate => 'No account yet? Create one';

  @override
  String get signInToSignIn => 'Have an account? Sign in';

  @override
  String get signInSendLink => 'No password? Email me a link';

  @override
  String get signInLinkSentTitle => 'Check your email';

  @override
  String signInLinkSentBody(String email) {
    return 'We sent a sign-in link to $email. Open it on this phone.';
  }

  @override
  String get signInBackToOptions => 'Use another way';

  @override
  String get signInSigningIn => 'Signing in…';

  @override
  String get signInBadEmail => 'Check the email address.';

  @override
  String get signInShortPassword => 'Use at least 8 characters.';

  @override
  String get authInvalidCredentials => 'Wrong email or password.';

  @override
  String get authEmailTaken =>
      'An account with this email exists. Sign in or ask for a link.';

  @override
  String get authLinkInvalid =>
      'This link expired or was already used. Ask for a new one.';

  @override
  String get authGoogleFailed => 'Google sign-in failed. Try another way.';

  @override
  String get authSessionExpired => 'Please sign in again.';

  @override
  String get authTooMany => 'Too many attempts. Try again in a minute.';

  @override
  String get emailVerified => 'Email confirmed.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsNameEmpty => 'Not set';

  @override
  String get settingsEmailUnverified => 'Not confirmed';

  @override
  String get settingsResendEmail => 'Send the confirmation again';

  @override
  String get settingsEmailSent => 'Email sent.';

  @override
  String get settingsAssistant => 'Assistant';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsConfirmActions => 'Confirm every sensitive action';

  @override
  String get settingsConfirmActionsHelp =>
      'When off, you get 3 seconds to cancel. Payments and deletions are always confirmed.';

  @override
  String get settingsVoiceReplies => 'Read replies aloud';

  @override
  String get settingsDevices => 'Devices';

  @override
  String get settingsThisDevice => 'This device';

  @override
  String get settingsUnknownDevice => 'Unknown device';

  @override
  String settingsLastUsed(String date) {
    return 'Last used $date';
  }

  @override
  String get settingsRemoveDevice => 'Sign out';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutEverywhere => 'Sign out everywhere';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteTitle => 'Delete your account?';

  @override
  String get settingsDeleteBody =>
      'Your data is erased for good in 7 days. You can cancel until then.';

  @override
  String get settingsDeleteConfirm => 'Delete';

  @override
  String settingsDeletionScheduled(String date) {
    return 'Your account will be deleted on $date.';
  }

  @override
  String get settingsCancelDeletion => 'Cancel deletion';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRetry => 'Try again';

  @override
  String get memoryTitle => 'Memory';

  @override
  String get memoryBody =>
      'What Alesle remembers to keep your commands short. The text of your messages is never kept.';

  @override
  String get memoryEmpty => 'Nothing remembered yet. Say “Remember: …”.';

  @override
  String get memoryKindPreference => 'Preference';

  @override
  String get memoryKindContact => 'Contact';

  @override
  String get memoryKindFact => 'Fact';

  @override
  String get memoryKindEpisode => 'Event';

  @override
  String get memoryForget => 'Forget';

  @override
  String get memoryForgetAll => 'Forget everything';

  @override
  String get memoryForgetAllTitle => 'Forget everything?';

  @override
  String get memoryForgetAllBody =>
      'Alesle deletes everything it remembered about you. This cannot be undone.';

  @override
  String get memoryForgotten => 'Forgotten.';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No tasks yet.';

  @override
  String get historyClear => 'Clear history';

  @override
  String get historyClearTitle => 'Clear the history?';

  @override
  String get historyClearBody =>
      'Every past task and what was said is deleted.';

  @override
  String get historyDelete => 'Delete';

  @override
  String get historyLoadMore => 'Show more';

  @override
  String get historyStatusDone => 'Done';

  @override
  String get historyStatusFailed => 'Failed';

  @override
  String get historyStatusCannot => 'Not possible';

  @override
  String get historyStatusStopped => 'Stopped';

  @override
  String get historyStatusInterrupted => 'Interrupted';

  @override
  String get settingsMemory => 'Memory';

  @override
  String get settingsHistory => 'History';

  @override
  String get settingsPlan => 'Plan and usage';

  @override
  String get billingTitle => 'Plan';

  @override
  String get billingPlanFree => 'Free';

  @override
  String billingUsed(Object percent) {
    return '$percent% used this month';
  }

  @override
  String billingResets(Object date) {
    return 'Limit resets on $date';
  }

  @override
  String get billingSimpleMode =>
      'Limit used up: only simple commands (calls, alarms, SMS) work.';

  @override
  String billingPaidUntil(Object date) {
    return 'Paid until $date';
  }

  @override
  String billingEndsOn(Object date) {
    return 'Ends on $date, won’t renew';
  }

  @override
  String get billingPastDue => 'We couldn’t renew your plan; you’re on Free.';

  @override
  String get billingCancel => 'Stop renewing';

  @override
  String get billingResume => 'Keep renewing';

  @override
  String get billingCancelTitle => 'Stop renewing?';

  @override
  String billingCancelBody(Object date) {
    return 'Your plan works until $date, then you’re on Free.';
  }

  @override
  String get billingPlans => 'Plans';

  @override
  String billingPerMonth(Object price) {
    return '$price UZS / month';
  }

  @override
  String billingPrice(Object price) {
    return '$price UZS';
  }

  @override
  String billingFeatureDaily(Object commands) {
    return '$commands commands a day';
  }

  @override
  String billingFeatureScreenDaily(Object tasks) {
    return '$tasks app tasks a day';
  }

  @override
  String get billingFeatureNoDaily => 'No daily cap';

  @override
  String get billingFeatureVision => 'Understands images on screen too';

  @override
  String get billingFeatureStrong => 'The strongest model for complex tasks';

  @override
  String get billingCurrent => 'Current plan';

  @override
  String get billingChoose => 'Choose';

  @override
  String get billingExtend => 'Extend';

  @override
  String get billingPackTitle => 'Extra limit';

  @override
  String get billingPackBody =>
      'More for this month. Your plan stays the same.';

  @override
  String billingAddMore(Object price) {
    return 'Add more · $price UZS';
  }

  @override
  String get billingPayTitle => 'Pay with';

  @override
  String get billingMethodCard => 'Bank card';

  @override
  String get billingSecure => 'Secure. Alesle never sees your card.';

  @override
  String get billingNoMethods =>
      'Payment isn’t available yet. Try again later.';

  @override
  String get billingPageNotOpened => 'Couldn’t open the payment page.';

  @override
  String get billingChecking => 'Checking the payment…';

  @override
  String get billingCheckingBody => 'This usually takes a few seconds.';

  @override
  String get billingPaid => 'Payment received';

  @override
  String get billingPaidBody => 'You’re all set.';

  @override
  String get billingNotPaid => 'Payment didn’t go through';

  @override
  String get billingNotPaidBody => 'Try again, or another way.';

  @override
  String get billingStillWaiting => 'Not confirmed yet';

  @override
  String get billingStillWaitingBody =>
      'As soon as the payment is confirmed, it switches on by itself.';

  @override
  String get billingCheckAgain => 'Check again';

  @override
  String get limitMonthTitle => 'This month is used up';

  @override
  String get limitMonthBody =>
      'Calls, alarms and SMS still work. Add more to use apps again.';

  @override
  String get limitDailyTitle => 'Today’s free limit is used up';

  @override
  String get limitDailyBody => 'Continue tomorrow, or go Pro for no daily cap.';

  @override
  String get limitUpgrade => 'Upgrade';

  @override
  String limitWaitUntil(Object date) {
    return 'Wait until $date';
  }

  @override
  String get limitWaitTomorrow => 'Wait until tomorrow';

  @override
  String usageHighNotice(Object percent) {
    return '$percent% of this month’s limit is used.';
  }

  @override
  String get taskAddMore => 'Add more';

  @override
  String get commonLater => 'Later';

  @override
  String get commonDone => 'Done';

  @override
  String get updateTitle => 'Update';

  @override
  String get updateAvailableTitle => 'A new version is here';

  @override
  String get updateAvailableBody => 'It takes about a minute.';

  @override
  String get updateRequiredBody =>
      'Update the app to keep going. It takes about a minute.';

  @override
  String get updateNow => 'Update';

  @override
  String get updateUpToDate => 'You have the latest version';

  @override
  String updateVersion(Object version) {
    return 'Version $version';
  }

  @override
  String updateNewVersion(Object version) {
    return 'New version: $version';
  }

  @override
  String updateDownloading(Object percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get updateInstalling => 'Installing…';

  @override
  String get updatePermissionNeeded =>
      'Allow Alesle to install apps, then come back and tap Update.';

  @override
  String get updateRejected =>
      'The file failed the check and wasn’t installed. Download the app from alesle.ai.';

  @override
  String get updateFailed => 'Couldn’t update. Try again.';

  @override
  String get updateStarted => 'Confirm the installation.';

  @override
  String get settingsUpdate => 'Updates';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsTerms => 'Terms of use';

  @override
  String get settingsRefund => 'Refund policy';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsLinkFailed => 'Couldn’t open the page.';

  @override
  String get reasonUpgrade =>
      'This version of the app is out of date. Please update it.';

  @override
  String get settingsDeleteGuide => 'About deleting your account';

  @override
  String get linkAlreadySignedIn =>
      'You’re already signed in. To switch accounts, sign out first.';

  @override
  String get linkVerifySignInFirst =>
      'To confirm the email, sign in to that account first, then open the link again.';
}
