import 'package:alesle_ai/app/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? gate(bool onboarded, bool signedIn, String at) =>
      gateFor(onboardingDone: onboarded, signedIn: signedIn, location: at);

  test('onboarding comes first, wherever the app opens', () {
    expect(gate(false, false, AppRoutes.home), AppRoutes.onboarding);
    expect(gate(false, true, AppRoutes.settings), AppRoutes.onboarding);
    expect(gate(false, false, AppRoutes.onboarding), isNull);
  });

  test('then signing in', () {
    expect(gate(true, false, AppRoutes.home), AppRoutes.signIn);
    expect(gate(true, false, AppRoutes.onboarding), AppRoutes.signIn);
    expect(gate(true, false, AppRoutes.signIn), isNull);
  });

  test('signed in: never back to onboarding or sign-in', () {
    expect(gate(true, true, AppRoutes.signIn), AppRoutes.home);
    expect(gate(true, true, AppRoutes.onboarding), AppRoutes.home);
    expect(gate(true, true, AppRoutes.settings), isNull);
    expect(gate(true, true, AppRoutes.home), isNull);
  });

  test('an outdated app can only update (EC-15)', () {
    String? outdated(String at) => gateFor(
      upgradeRequired: true,
      onboardingDone: true,
      signedIn: true,
      location: at,
    );
    expect(outdated(AppRoutes.home), AppRoutes.updateRequired);
    expect(outdated(AppRoutes.signIn), AppRoutes.updateRequired);
    expect(outdated(AppRoutes.updateRequired), isNull);
    // Updated meanwhile: the screen gives way.
    expect(gate(true, true, AppRoutes.updateRequired), AppRoutes.home);
  });
}
