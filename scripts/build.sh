#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
APP_NAME="Scap"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/${APP_NAME}.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
SRC_DIR="$ROOT_DIR/Sources"
RESOURCE_SRC_DIR="$ROOT_DIR/Resources"
MODULE_CACHE="$BUILD_DIR/module-cache"

CONFIG="${1:-release}"
ARCH=$(uname -m)
TARGET="${ARCH}-apple-macos13.0"

SWIFTC_FLAGS=()
if [[ "$CONFIG" == "debug" ]]; then
  SWIFTC_FLAGS+=("-g" "-Onone")
else
  SWIFTC_FLAGS+=("-O")
fi

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$MODULE_CACHE"

SOURCES=()
while IFS= read -r -d '' file; do
  SOURCES+=("$file")
done < <(find "$SRC_DIR" -name "*.swift" -print0)

xcrun --sdk macosx swiftc \
  "${SOURCES[@]}" \
  -o "$MACOS_DIR/$APP_NAME" \
  -target "$TARGET" \
  -module-cache-path "$MODULE_CACHE" \
  -framework Cocoa \
  -framework Carbon \
  -framework ApplicationServices \
  "${SWIFTC_FLAGS[@]}"

cp "$RESOURCE_SRC_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"

if [[ -f "$RESOURCE_SRC_DIR/StatusIcon.png" ]]; then
  cp "$RESOURCE_SRC_DIR/StatusIcon.png" "$RESOURCES_DIR/StatusIcon.png"
fi

echo "Built $APP_DIR"
