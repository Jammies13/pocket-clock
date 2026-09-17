#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Use the runner's installed iPhoneOS SDK; no Apple account or signing keys.
xcodebuild \
  -project PocketClock.xcodeproj \
  -scheme PocketClock \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY= \
  build

python3 scripts/package-ipa.py
