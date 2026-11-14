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
codesign --force --deep --sign - "$OUT"
echo "Built $OUT"
