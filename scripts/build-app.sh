#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
export CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache"
swift build --configuration release --scratch-path .build --disable-sandbox
app_path="$PWD/build/Goal Layer.app"
mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources"
cp .build/release/GoalLayer "$app_path/Contents/MacOS/GoalLayer"
cat > "$app_path/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Goal Layer</string>
<key>CFBundleDisplayName</key><string>Goal Layer</string>
<key>CFBundleIdentifier</key><string>org.goallayer.app</string>
<key>CFBundleExecutable</key><string>GoalLayer</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$app_path"
printf 'Built local development app: %s\n' "$app_path"
printf 'Ad-hoc signature only. This is not a notarized distribution.\n'
