#!/bin/bash
# Installs the player's own SimCopter (1996) data for the data-free Mac release of SimCopter Remake.
#
# Usage: double-click this file, or run it with the path to your SimCopter CD, ISO image or an
# existing SimCopter install folder:
#   ./Install\ SimCopter\ Data.command "/Volumes/SimCopter"
#   ./Install\ SimCopter\ Data.command ~/Downloads/SimCopter.iso
#
# The files go to ~/Library/Application Support/SimCopterRemake/SimCopter, which the game searches
# in addition to its own bundle. Nothing inside SimCopterRemake.app is modified. If ffmpeg and
# python3 are available, the intro movies, menu sky, career previews and loading animation are
# converted from the original Smacker files too; without them the game still runs and simply skips
# or substitutes those.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/Library/Application Support/SimCopterRemake/SimCopter"
MOUNTED=""

cleanup() { if [ -n "$MOUNTED" ]; then hdiutil detach -quiet "$MOUNTED" || true; fi; }
trap cleanup EXIT

find_install_dir() {
    # A folder that holds the original data trees, case-insensitively: the CD's SIMCOPTER folder,
    # an installed copy, or that folder's parent.
    local base="$1" d
    for d in "$base" "$base"/*; do
        [ -d "$d" ] || continue
        if ls "$d" 2>/dev/null | grep -qix "geo" && ls "$d" 2>/dev/null | grep -qix "cities"; then
            echo "$d"; return 0
        fi
    done
    return 1
}

SRC="${1:-}"
if [ -z "$SRC" ]; then
    for v in /Volumes/*; do
        if found=$(find_install_dir "$v"); then SRC="$found"; break; fi
    done
fi
if [ -z "$SRC" ]; then
    echo "Drag your SimCopter CD, ISO image or install folder onto this window, then press Return:"
    read -r SRC
    SRC="${SRC%\"}"; SRC="${SRC#\"}"; SRC="${SRC%\'}"; SRC="${SRC#\'}"
    SRC="${SRC//\\ / }"
    SRC="${SRC%"${SRC##*[![:space:]]}"}"
fi

if [ -f "$SRC" ]; then
    echo "Mounting $SRC ..."
    MOUNTED=$(hdiutil attach -readonly -nobrowse -noautoopen "$SRC" | awk -F'\t' '/\/Volumes\//{print $NF}' | tail -1)
    SRC="$MOUNTED"
fi

if ! INSTALL=$(find_install_dir "$SRC"); then
    echo "Could not find SimCopter data (geo and cities folders) in: $SRC" >&2
    exit 1
fi

echo "Copying SimCopter data from $INSTALL"
echo "                         to $DEST"
mkdir -p "$DEST"
for name in bmp cities geo sound tweak x smk fonts help; do
    match=$(ls "$INSTALL" | grep -ix "$name" | head -1 || true)
    [ -n "$match" ] && rsync -a "$INSTALL/$match/" "$DEST/$name/"
done
chmod -R u+w "$DEST"

SMK="$DEST/smk"
GEN="$DEST/Generated"
if command -v ffmpeg >/dev/null && command -v ffprobe >/dev/null && command -v python3 >/dev/null; then
    echo "Converting the original movies with ffmpeg ..."
    pick() { ls "$SMK" | grep -ix "$1" | head -1; }
    python3 -I "$HERE/tools/BakeIntroMovies.py" --source "$SMK" --output "$GEN/Movies/Intro" || echo "Intro movies skipped."
    python3 -I "$HERE/tools/BakeLoadingScreen.py" --source "$SMK/$(pick hrglass.smk)" --output "$GEN/Loading/HRGLASS.png" || echo "Loading animation skipped."
    python3 -I "$HERE/tools/BakeMenuSky.py" --source "$SMK/$(pick menusky.smk)" --output "$GEN/Movies/MENUSKY.mp4" || echo "Menu sky skipped."
    python3 -I "$HERE/tools/BakeCareerPreviews.py" --source-dir "$SMK" --output-dir "$GEN/Movies/Career" || echo "Career previews skipped."
else
    echo
    echo "ffmpeg not found, so the intro movies and animated menus were not converted."
    echo "The game works without them. To add them later: brew install ffmpeg, then run this again."
fi

echo
echo "Done. You can now open SimCopterRemake.app."
