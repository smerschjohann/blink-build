#!/usr/bin/env bash
# Builds an unsigned Blink .app via xcodebuild archive and packages it as an .ipa.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CONFIGURATION="${CONFIGURATION:-Debug}"
ARCHIVE="build/Blink.xcarchive"

xcodebuild -version
xcodebuild archive \
  -project blink/Blink.xcodeproj \
  -scheme Blink \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=NO

APP="$ARCHIVE/Products/Applications/Blink.app"
rm -rf build/Payload
mkdir -p build/Payload
cp -R "$APP" build/Payload/
( cd build && zip -qry Blink-unsigned.ipa Payload )

echo "==> build/Blink-unsigned.ipa"
