import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/auth/data/auth_data_providers.dart';
import 'package:alesle_ai/features/auth/presentation/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeAuthRepository auth;

  Future<void> pump(WidgetTester tester, {bool google = true}) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    auth = FakeAuthRepository(googleAvailable: google);
    await pumpLocalized(
      tester,
      const SignInScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, String key, String text) =>
      tester.enterText(find.byKey(Key(key)), text);

  testWidgets('offers Google first, then email', (WidgetTester tester) async {
    await pump(tester);
    expect(find.text('Alesle’ga kiring'), findsOneWidget);
    await tap(tester, 'sign-in-google');
    expect(auth.calls, <String>['google']);
  });

  testWidgets('a cancelled Google picker is not an error', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    auth.googleCancelled = true;
    await tap(tester, 'sign-in-google');
    expect(auth.calls, <String>['google-cancelled']);
    expect(find.byKey(const Key('sign-in-error')), findsNothing);
  });

  testWidgets('without Google, email is the only way', (
    WidgetTester tester,
  ) async {
    await pump(tester, google: false);
    expect(find.byKey(const Key('sign-in-google')), findsNothing);
    expect(find.byKey(const Key('sign-in-email')), findsOneWidget);
  });

  testWidgets('signs in with a password, checking the fields first', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    await tap(tester, 'sign-in-email');
    await tap(tester, 'sign-in-submit');
    expect(find.text('Email manzilini tekshiring.'), findsOneWidget);
    expect(find.text('Parol kamida 8 belgi bo‘lsin.'), findsOneWidget);
    expect(auth.calls, isEmpty);

    await fill(tester, 'sign-in-email-field', 'aziz@example.com');
    await fill(tester, 'sign-in-password', 'correct horse');
    await tap(tester, 'sign-in-submit');
    expect(auth.calls, <String>['login:aziz@example.com']);
  });

  testWidgets('shows why a sign-in failed', (WidgetTester tester) async {
    await pump(tester);
    auth.failure = const ServerFailure(
      code: ErrorCode.invalidCredentials,
      statusCode: 401,
    );
    await tap(tester, 'sign-in-email');
    await fill(tester, 'sign-in-email-field', 'aziz@example.com');
    await fill(tester, 'sign-in-password', 'wrong password');
    await tap(tester, 'sign-in-submit');
    expect(find.text('Email yoki parol noto‘g‘ri.'), findsOneWidget);

    auth.failure = const NetworkFailure();
    await tap(tester, 'sign-in-submit');
    expect(find.text('Internet aloqasini tekshiring'), findsOneWidget);
  });

  testWidgets('creates an account with a name', (WidgetTester tester) async {
    await pump(tester);
    await tap(tester, 'sign-in-email');
    await tap(tester, 'sign-in-switch');
    expect(find.text('Akkaunt yaratish'), findsOneWidget);
    await fill(tester, 'sign-in-name', 'Aziz');
    await fill(tester, 'sign-in-email-field', 'aziz@example.com');
    await fill(tester, 'sign-in-password', 'correct horse');
    await tap(tester, 'sign-in-submit');
    expect(auth.calls, <String>['register:aziz@example.com:Aziz']);

    auth.failure = const ServerFailure(
      code: ErrorCode.emailTaken,
      statusCode: 409,
    );
    await tap(tester, 'sign-in-submit');
    expect(
      find.text('Bu email bilan akkaunt bor. Kiring yoki havola so‘rang.'),
      findsOneWidget,
    );
  });

  testWidgets('emails a sign-in link and says where it went', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    await tap(tester, 'sign-in-email');
    await tap(tester, 'sign-in-send-link');
    expect(find.text('Email manzilini tekshiring.'), findsOneWidget);
    expect(auth.calls, isEmpty);

    await fill(tester, 'sign-in-email-field', 'aziz@example.com');
    await tap(tester, 'sign-in-send-link');
    expect(auth.calls, <String>['link:aziz@example.com']);
    expect(find.text('Emailingizni tekshiring'), findsOneWidget);
    expect(find.textContaining('aziz@example.com'), findsOneWidget);

    await tap(tester, 'sign-in-other-way');
    expect(find.byKey(const Key('sign-in-google')), findsOneWidget);
  });

  testWidgets('back and the system back return to the options', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    await tap(tester, 'sign-in-email');
    await tap(tester, 'sign-in-back');
    expect(find.byKey(const Key('sign-in-google')), findsOneWidget);

    await tap(tester, 'sign-in-email');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sign-in-google')), findsOneWidget);
  });
}
