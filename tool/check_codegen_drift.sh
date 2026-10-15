#!/usr/bin/env bash
# Regenerates every generated artifact and fails if the result differs from
# what is committed: Pigeon (Dart + Kotlin), the OpenAPI client, freezed/json/
# retrofit output, and gen-l10n. A generated file edited by hand, or a source
# changed without regenerating, is caught here instead of at runtime.
#
# `git status --porcelain` (not `git diff`) so an UNTRACKED generated file also
# fails — `git diff` passes silently on paths git does not know.
set -euo pipefail
cd "$(dirname "$0")/.."

dart run pigeon --input pigeons/agent_api.dart
dart run swagger_parser
dart run build_runner build -d
flutter gen-l10n
dart format lib/core/api/generated lib/core/platform/generated lib/app/l10n >/dev/null

paths=(
  lib/core/api/generated
  lib/core/platform/generated
  android/app/src/main/kotlin/com/alesle/ai/agent/generated
  lib/app/l10n
)
dirty="$(git status --porcelain -- "${paths[@]}")"
if [[ -n "$dirty" ]]; then
  echo "Generated code differs from what is committed:" >&2
  echo "$dirty" >&2
  echo "Regenerate (tool/check_codegen_drift.sh) and commit the result." >&2
  exit 1
fi
echo "codegen drift: none"
