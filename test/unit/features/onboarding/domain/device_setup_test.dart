import 'package:alesle_ai/features/onboarding/domain/device_setup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DeviceSetup on(String manufacturer, int sdkInt) => DeviceSetup(
    batteryOptimizationIgnored: false,
    manufacturer: manufacturer,
    sdkInt: sdkInt,
  );

  test('autostart screens only for the makers that have one', () {
    for (final String maker in autostartMakers) {
      expect(on(maker, 34).hasAutostartScreen, isTrue, reason: maker);
    }
    expect(on('google', 34).hasAutostartScreen, isFalse);
    expect(on('samsung', 34).hasAutostartScreen, isFalse);
  });

  test('restricted settings from Android 13', () {
    expect(on('google', 32).mayRestrictSettings, isFalse);
    expect(on('google', 33).mayRestrictSettings, isTrue);
    expect(on('xiaomi', 36).mayRestrictSettings, isTrue);
  });

  test('steps run in the order the screen shows them', () {
    expect(OnboardingStep.values, <OnboardingStep>[
      OnboardingStep.welcome,
      OnboardingStep.language,
      OnboardingStep.privacy,
      OnboardingStep.permissions,
      OnboardingStep.accessibility,
      OnboardingStep.battery,
      OnboardingStep.done,
    ]);
  });
}
