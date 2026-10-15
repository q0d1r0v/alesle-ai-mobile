import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppSettings', () {
    test('defaults: confirm on, voice replies on, phone language', () {
      const AppSettings settings = AppSettings();
      expect(settings.onboardingDone, isFalse);
      expect(settings.language, isNull);
      expect(settings.voiceReplies, isTrue);
      expect(settings.confirmSensitiveActions, isTrue);
    });

    test('copyWith changes only what is given; clearLanguage resets', () {
      const AppSettings base = AppSettings(language: 'ru');
      final AppSettings changed = base.copyWith(
        onboardingDone: true,
        voiceReplies: false,
        confirmSensitiveActions: false,
      );
      expect(changed.language, 'ru');
      expect(changed.onboardingDone, isTrue);
      expect(changed.voiceReplies, isFalse);
      expect(changed.confirmSensitiveActions, isFalse);
      expect(base.copyWith(language: 'en').language, 'en');
      expect(base.copyWith(clearLanguage: true).language, isNull);
    });

    test('value equality', () {
      expect(
        const AppSettings(language: 'uz'),
        const AppSettings(language: 'uz'),
      );
      expect(
        const AppSettings(language: 'uz').hashCode,
        const AppSettings(language: 'uz').hashCode,
      );
      expect(const AppSettings(), isNot(const AppSettings(language: 'uz')));
    });
  });

  group('AppSettingsStore', () {
    test('an empty phone reads the defaults', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final AppSettingsStore store = await AppSettingsStore.load();
      expect(store.read(), const AppSettings());
    });

    test('writes and reads back every field', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final AppSettingsStore store = await AppSettingsStore.load();
      const AppSettings settings = AppSettings(
        onboardingDone: true,
        language: 'uz',
        voiceReplies: false,
        confirmSensitiveActions: false,
      );
      await store.write(settings);
      expect(store.read(), settings);
      expect((await AppSettingsStore.load()).read(), settings);

      await store.write(settings.copyWith(clearLanguage: true));
      expect(store.read().language, isNull);
    });

    test('an unknown stored language follows the phone', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'language': 'de',
      });
      expect((await AppSettingsStore.load()).read().language, isNull);
    });
  });

  group('appSettingsProvider', () {
    test('needs the store from bootstrap', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      expect(() => container.read(appSettingsStoreProvider), throwsA(anything));
    });

    test('update changes the state and persists it', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final AppSettingsStore store = await AppSettingsStore.load();
      final ProviderContainer container = ProviderContainer(
        overrides: [appSettingsStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      expect(container.read(appSettingsProvider), const AppSettings());
      await container
          .read(appSettingsProvider.notifier)
          .update(
            (AppSettings s) => s.copyWith(confirmSensitiveActions: false),
          );
      expect(
        container.read(appSettingsProvider).confirmSensitiveActions,
        isFalse,
      );
      expect(store.read().confirmSensitiveActions, isFalse);
    });
  });
}
