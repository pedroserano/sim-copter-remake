#!/bin/bash
# Builds "Install SimCopter Data.app" from installer/Installer.applescript, with install.sh in its
# Resources, and signs it ad hoc.   build_installer_app.sh <output .app path>
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="${1:?output .app path}"
rm -rf "$OUT"
osacompile -o "$OUT" "$HERE/installer/Installer.applescript"
cp "$HERE/installer/install.sh" "$OUT/Contents/Resources/install.sh"
chmod +x "$OUT/Contents/Resources/install.sh"
# Same icon as the game (Tools/MacRelease/icon, drawn by DrawIcon.swift).
cp "$HERE/icon/AppIcon.icns" "$OUT/Contents/Resources/applet.icns"
rm -f "$OUT/Contents/Resources/Assets.car"
/usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" "$OUT/Contents/Info.plist" 2>/dev/null || true
codesign --force --deep --sign - "$OUT"
echo "Built $OUT"
