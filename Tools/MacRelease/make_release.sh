#!/bin/bash
# Turns a packaged Mac build into a data-free release zip that is safe to publish.
#
#   Tools/MacRelease/make_release.sh <archive dir holding SimCopterRemake.app> <version>
#
# Packaging bundles the developer's original SimCopter data (Contents/UE/SimCopter) and the movies
# baked from it (Content/Generated). Neither may be redistributed, so both are removed here and the
# player supplies their own copy with "Install SimCopter Data.command". The script refuses to write
# the zip if anything that looks like original data is still inside the app.
set -euo pipefail

ARCHIVE="${1:?archive dir}"
VERSION="${2:?version, e.g. 1.0.1-mac1}"
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
APP_SRC="$(find "$ARCHIVE" -maxdepth 3 -name 'SimCopterRemake*.app' -type d | head -1)"
[ -n "$APP_SRC" ] || { echo "No SimCopterRemake .app under $ARCHIVE" >&2; exit 1; }

OUT="$REPO/SimCopterRemake/Saved/MacRelease"
STAGE="$OUT/SimCopter Remake $VERSION"
ZIP="$OUT/SimCopterRemake-$VERSION-mac-arm64.zip"
rm -rf "$STAGE" "$ZIP"
mkdir -p "$STAGE/tools"

ditto "$APP_SRC" "$STAGE/SimCopterRemake.app"
UE="$STAGE/SimCopterRemake.app/Contents/UE"
rm -rf "$UE/SimCopter" "$UE/SimCopterRemake/Content/Generated"

# Anything with an original-data extension left loose in the bundle stops the release.
LEFT=$(find "$STAGE/SimCopterRemake.app" -type f \( -iname '*.smk' -o -iname '*.sc2' -o -iname '*.twk' \
    -o -iname '*.max' -o -iname '*.df' -o -iname '*.wav' -o -iname '*.bmp' -o -iname '*.mp4' \
    -o -iname '*.geo' -o -iname 'HRGLASS.png' \) | head -20)
if [ -n "$LEFT" ]; then
    echo "Original-looking data is still inside the app; not releasing:" >&2
    echo "$LEFT" >&2
    exit 1
fi

# The bundle changed, so its seal must be redone. Ad hoc: the release is not notarized.
codesign --force --deep --sign - "$STAGE/SimCopterRemake.app"

cp "$REPO/Tools/MacRelease/Install SimCopter Data.command" "$STAGE/"
chmod +x "$STAGE/Install SimCopter Data.command"
cp "$REPO/Tools/MacRelease/README.txt" "$STAGE/"
for s in BakeIntroMovies BakeLoadingScreen BakeMenuSky BakeCareerPreviews; do
    cp "$REPO/Tools/Unreal/$s.py" "$STAGE/tools/"
done

(cd "$OUT" && ditto -c -k --sequesterRsrc --keepParent "$(basename "$STAGE")" "$ZIP")
echo "Release zip: $ZIP ($(du -h "$ZIP" | cut -f1))"
