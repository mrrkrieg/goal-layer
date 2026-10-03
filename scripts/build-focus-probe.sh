#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
probe_path="$PWD/build/Focus Probe.app"
mkdir -p "$probe_path/Contents/MacOS"
xcrun swiftc -parse-as-library -swift-version 6 -target arm64-apple-macosx14.0 -module-cache-path "$PWD/.build/ModuleCache" tools/FocusProbe.swift -o "$probe_path/Contents/MacOS/FocusProbe"
cat > "$probe_path/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Focus Probe</string>
<key>CFBundleIdentifier</key><string>org.goallayer.focus-probe</string>
<key>CFBundleExecutable</key><string>FocusProbe</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
</dict></plist>
PLIST
codesign --force --sign - "$probe_path"
printf 'Built synthetic-only native Focus Probe: %s\n' "$probe_path"
