#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
APP_NAME="Scap"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/${APP_NAME}.app"
STAGE_DIR="$BUILD_DIR/dmg-stage"
DMG_DIR="$BUILD_DIR/dmg"
PLIST="$ROOT_DIR/Resources/Info.plist"

if [[ ! -d "$APP_DIR" ]]; then
  "$ROOT_DIR/scripts/build.sh" release
fi

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PLIST")
DMG_NAME="${APP_NAME}-${VERSION}.dmg"

rm -rf "$STAGE_DIR" "$DMG_DIR"
mkdir -p "$STAGE_DIR" "$DMG_DIR"

cp -R "$APP_DIR" "$STAGE_DIR/"
ln -s /Applications "$STAGE_DIR/Applications"

hdiutil create -volname "$APP_NAME" -srcfolder "$STAGE_DIR" -ov -format UDZO "$DMG_DIR/$DMG_NAME"

echo "Created $DMG_DIR/$DMG_NAME"
