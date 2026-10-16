# alesle-ai-mobile

Android app for **Alesle AI**, a personal AI agent: the user speaks a command
and the agent carries it out on the phone through an AccessibilityService.

Backend: [`../alesle-ai-api`](../alesle-ai-api). Rules: [AGENTS.md](AGENTS.md).

## Requirements

- Flutter 3.47.6 (Dart 3.13), JDK 17, Android SDK (API 36), an emulator or device on Android 11+.
- Node + yarn only for git hooks (`yarn install` once).
- `dart pub global activate patrol_cli` for the E2E suite.

## Run

```bash
flutter pub get
yarn install                       # git hooks (husky + commitlint)

# Backend on the host: see ../alesle-ai-api/README.md (listens on :3000).
# The emulator reaches the host as 10.0.2.2 — that is what env/dev.json uses.
flutter run --dart-define-from-file=env/dev.json
```

On a physical phone, forward the API over USB and point the build at it, then
sign in in the app (email + password, or a magic link: locally the emails land
in mailpit, http://127.0.0.1:8026). Google sign-in appears when the build gets
the web OAuth client ID the API accepts (`GOOGLE_CLIENT_IDS`):

```bash
adb reverse tcp:3000 tcp:3000
flutter run --dart-define-from-file=env/dev.json \
  --dart-define=API_BASE_URL=http://127.0.0.1:3000 \
  [--dart-define=GOOGLE_SERVER_CLIENT_ID=<web client id>.apps.googleusercontent.com]
```

Magic and confirmation links (`https://alesle.ai/auth/...`) open the app through
App Links once the website serves `.well-known/assetlinks.json` with the release
certificate's SHA-256; until then `adb shell am start -a android.intent.action.VIEW
-d '<link>' com.alesle.ai` opens one by hand.

Debug builds allow plain http only to 127.0.0.1, localhost and 10.0.2.2.

## Distribution

One build, `com.alesle.ai`, distributed only as a signed APK from our website —
no Google Play ([ADR 0005](../alesle-ai-api/docs/adr/0005-website-only-distribution.md)).
"Confirm every sensitive action" is a user setting (on by default), not a build flavor.

## Release signing

Release APKs are signed with the release key (`alias alesle`), kept outside the
repository with an offline backup. Losing it means installed apps can never
be updated. `android/key.properties` (git-ignored) points Gradle at it:

```properties
storeFile=/home/<you>/keys/alesle-release.jks
storePassword=…
keyAlias=alesle
keyPassword=…
```

Without the file, `flutter build apk --release` fails on purpose; debug builds
do not need it.

## Code generation

```bash
dart run pigeon --input pigeons/agent_api.dart   # Dart ⇄ Kotlin bridge
dart run swagger_parser                          # API client from openapi/alesle-ai-api.json
dart run build_runner build -d                   # freezed / json / retrofit
flutter gen-l10n                                 # uz / ru / en strings
tool/check_codegen_drift.sh                      # all of the above + "is it committed?"
```

## Test

```bash
tool/verify.sh                                   # everything except on-device suites
flutter test integration_test --dart-define-from-file=env/dev.json
patrol test --dart-define-from-file=env/dev.json
```

> Headless emulators (`-no-window`, swiftshader) may not render frames with
> Impeller; tests still pass because they read the widget tree. To *see* the
> app on such an emulator, run with `--no-enable-impeller`.

## Try the agent runtime on a phone (debug builds)

On the phone: long-press the "Alesle AI" title on the home screen to open the
agent console (snapshot, actions with a delay so you can switch apps, start
and stop a task). From a computer:

Until the agent loop exists, a debug-only receiver also takes snapshots and
runs single actions over adb. Answers come back in the `am broadcast` output;
nothing is written to disk or logs. Release builds do not contain it.

```bash
flutter build apk --debug --dart-define-from-file=env/dev.json
adb install -r build/app/outputs/flutter-apk/app-debug.apk
# Settings → Accessibility → Alesle AI agent → On (or, over adb:)
adb shell settings put secure enabled_accessibility_services \
  com.alesle.ai/com.alesle.ai.agent.AlesleAccessibilityService

R=com.alesle.ai/.debug.AgentDebugReceiver
adb shell am broadcast -n $R --es cmd snapshot          # {"captureMs":…, "snapshot":{…}}
adb shell am broadcast -n $R --es cmd action --es json "'{\"type\":\"tap\",\"nodeId\":4}'"
adb shell am broadcast -n $R --es cmd action --es json "'{\"type\":\"launch_app\",\"name\":\"Calculator\"}'"
```

Other commands: `task_start --es step '…' --es url http://127.0.0.1:3000 --es token <token>`
(a full task through the API, with the overlay), `task_stop`, `status`. Node ids
refer to the last `snapshot`. The action format is documented in
`android/app/src/main/kotlin/com/alesle/ai/agent/protocol/ActionJson.kt`.

Installing over adb skips Android 13+ "Restricted settings". Before a release,
also install the APK from a browser download and enable accessibility by hand.
