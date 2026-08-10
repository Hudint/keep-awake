#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="KeepAwake"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

swiftc -O \
  -target arm64-apple-macos13.0 \
  -o "$APP_DIR/Contents/MacOS/$APP_NAME" \
  Sources/main.swift

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>KeepAwake</string>
	<key>CFBundleDisplayName</key>
	<string>KeepAwake</string>
	<key>CFBundleExecutable</key>
	<string>KeepAwake</string>
	<key>CFBundleIdentifier</key>
	<string>de.hudint.KeepAwake</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSHighResolutionCapable</key>
	<true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP_DIR" >/dev/null 2>&1 || true

echo "Built: $(pwd)/$APP_DIR"
