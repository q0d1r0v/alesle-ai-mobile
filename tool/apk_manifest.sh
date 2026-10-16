#!/usr/bin/env bash
# Prints the release manifest for a signed APK (SOW 02 §3): version from the
# APK itself, SHA-256 of the file and of its signing certificate, size, and
# minSupportedVersionCode + notes from release/next.json.
#
#   tool/apk_manifest.sh <apk> <apk-url>
#
# The output is the body CI posts to POST /v1/app/releases.
set -euo pipefail
cd "$(dirname "$0")/.."

apk="${1:?usage: tool/apk_manifest.sh <apk> <apk-url>}"
url="${2:?usage: tool/apk_manifest.sh <apk> <apk-url>}"
[[ "$url" == https://* ]] || { echo "apk url must be https" >&2; exit 1; }

sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
tools="$(ls -d "$sdk"/build-tools/* | sort -V | tail -1)"

# The first line ("package: …"); read it all, so no SIGPIPE under pipefail.
badging="$("$tools/aapt2" dump badging "$apk")"
badging="${badging%%$'\n'*}"
package="$(sed -E "s/^package: name='([^']*)'.*/\1/" <<<"$badging")"
version_code="$(sed -E "s/.*versionCode='([0-9]+)'.*/\1/" <<<"$badging")"
version_name="$(sed -E "s/.*versionName='([^']*)'.*/\1/" <<<"$badging")"
[[ "$package" == "com.alesle.ai" ]] || { echo "not com.alesle.ai: $package" >&2; exit 1; }

# One signer only: an update must be signed by exactly the release key.
certs="$("$tools/apksigner" verify --print-certs "$apk" \
  | sed -nE 's/.*certificate SHA-256 digest: ([0-9a-f]{64}).*/\1/p')"
[[ "$(wc -l <<<"$certs")" == "1" && -n "$certs" ]] || { echo "expected exactly one signer" >&2; exit 1; }
cert_sha256="$certs"
sha256="$(sha256sum "$apk" | cut -d' ' -f1)"
size="$(stat -c %s "$apk")"

jq -n \
  --argjson versionCode "$version_code" \
  --arg versionName "$version_name" \
  --arg apkUrl "$url" \
  --arg sha256 "$sha256" \
  --arg certSha256 "$cert_sha256" \
  --argjson sizeBytes "$size" \
  --slurpfile next release/next.json \
  '{versionCode: $versionCode, versionName: $versionName, apkUrl: $apkUrl,
    sha256: $sha256, certSha256: $certSha256, sizeBytes: $sizeBytes,
    minSupportedVersionCode: $next[0].minSupportedVersionCode,
    notes: $next[0].notes}'
