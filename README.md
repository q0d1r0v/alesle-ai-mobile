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
flutter run --flavor direct --dart-define-from-file=env/dev.json
flutter run --flavor play   --dart-define-from-file=env/dev.json
```

On a physical device, put your machine's LAN address in a copy of `env/dev.json`.

## Flavors

| Flavor | Package | Who it's for |
|---|---|---|
| `play` | `com.alesle.ai` | Google Play. Every sensitive agent action needs the user's confirmation (Play policy). |
| `direct` | `com.alesle.ai.direct` | APK from the website. The agent acts autonomously. |

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
flutter test integration_test --flavor play --dart-define-from-file=env/dev.json
patrol test --flavor play --dart-define-from-file=env/dev.json
patrol test --flavor direct --package-name com.alesle.ai.direct --dart-define-from-file=env/dev.json
```

> Headless emulators (`-no-window`, swiftshader) may not render frames with
> Impeller; tests still pass because they read the widget tree. To *see* the
> app on such an emulator, run with `--no-enable-impeller`.
