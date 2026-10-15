#!/usr/bin/env bash
# Everything CI checks except on-device tests. Run before pushing.
#
#   tool/verify.sh            # full
#   tool/verify.sh --fast     # pre-commit subset (no Gradle, no goldens)
set -euo pipefail
cd "$(dirname "$0")/.."

fast=false
[[ "${1:-}" == "--fast" ]] && fast=true

echo "▶ format";   dart format --output=none --set-exit-if-changed lib test tool integration_test patrol_test pigeons
echo "▶ analyze";  flutter analyze --fatal-infos
echo "▶ tests";    flutter test --exclude-tags golden --coverage
echo "▶ coverage"; dart run tool/check_coverage.dart

if [[ "$fast" == false ]]; then
  echo "▶ goldens"; flutter test --tags golden
  echo "▶ android: Kotlin unit tests, ktlint, Android Lint"
  (cd android && ./gradlew --console=plain -q \
    testPlayDebugUnitTest testDirectDebugUnitTest :app:ktlintCheck :app:lintPlayDebug :app:lintDirectDebug)
  echo "▶ build both flavors"
  flutter build apk --debug --flavor play --dart-define-from-file=env/dev.json
  flutter build apk --debug --flavor direct --dart-define-from-file=env/dev.json
fi
echo "✓ verify passed"
