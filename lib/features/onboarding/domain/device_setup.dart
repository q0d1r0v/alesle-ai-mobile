/// What onboarding asks the phone for (SOW 09 §2).
enum SetupPermission { microphone, contacts, notifications }

enum PermissionStatus {
  granted,
  denied,

  /// "Don't ask again": only the app's settings page can change it.
  permanentlyDenied,
}

/// Phone makers with their own "autostart" screen (SOW 03 §8.1).
const Set<String> autostartMakers = <String>{
  'xiaomi',
  'redmi',
  'poco',
  'oppo',
  'realme',
  'vivo',
  'huawei',
  'honor',
};

final class DeviceSetup {
  const DeviceSetup({
    required this.batteryOptimizationIgnored,
    required this.manufacturer,
    required this.sdkInt,
  });

  final bool batteryOptimizationIgnored;
  final String manufacturer;
  final int sdkInt;

  bool get hasAutostartScreen => autostartMakers.contains(manufacturer);

  /// Android 13+ blocks accessibility for sideloaded apps until the user
  /// allows "restricted settings" (ADR 0005: we ship outside the Play Store).
  bool get mayRestrictSettings => sdkInt >= 33;
}

/// The onboarding screens, in order. Sign-in joins in Sprint 5.
enum OnboardingStep {
  welcome,
  language,
  privacy,
  permissions,
  accessibility,
  battery,
  done,
}

/// Throws a `Failure` from core/errors when the platform call fails.
abstract interface class DeviceSetupRepository {
  Future<PermissionStatus> status(SetupPermission permission);

  Future<PermissionStatus> request(SetupPermission permission);

  Future<DeviceSetup> setup();

  Future<bool> accessibilityEnabled();

  Future<void> openAccessibilitySettings();

  /// App info, where "Allow restricted settings" lives.
  Future<void> openAppDetails();

  Future<void> requestBatteryExemption();

  /// False when the maker has no known screen and app info opened instead.
  Future<bool> openAutostart();
}
