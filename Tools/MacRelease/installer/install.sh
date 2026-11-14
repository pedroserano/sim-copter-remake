#!/bin/bash
# Installs the player's own SimCopter (1996) data for the data-free Mac release of SimCopter Remake.
# Run by "Install SimCopter Data.app"; can also be run directly: install.sh [CD | ISO | folder].
#
# Needs nothing beyond a stock macOS: no Homebrew, no Python, no admin rights. The original data
# goes to ~/Library/Application Support/SimCopterRemake/SimCopter, which the game searches besides
# its own bundle, so the app is never modified. The intro, menu, career and loading movies are
# converted from the original Smacker files with ffmpeg: an installed one if present, otherwise a
# pinned, checksum-verified static Apple Silicon build downloaded into Application Support. If that
# fails the data is still installed and the game simply skips those movies.
#
# Progress goes to $SIMCOPTER_STATUS (one line per step) when set, for the app's progress bar.
set -uo pipefail

SUPPORT="$HOME/Library/Application Support/SimCopterRemake"
DEST="$SUPPORT/SimCopter"
GEN="$DEST/Generated"
FFDIR="$SUPPORT/ffmpeg"
STATUS="${SIMCOPTER_STATUS:-/dev/null}"
MOUNTED=""

# Pinned ffmpeg 9.0.2 static macOS arm64 builds (https://ffmpeg.martin-riedl.de), with the
# publisher's SHA-256 checksums. A mismatch is treated as no ffmpeg.
FF_BASE="https://ffmpeg.martin-riedl.de/download/macos/arm64/1789931890_9.0.2"
FF_SHA_ffmpeg="c8ed4c4e6978a03c485edbfe4e0a5dc2380f8a30bba5150531b31b094492d924"
FF_SHA_ffprobe="fcbe839537485eaee7a7a8bc5cbc0f90d53617e80943e8a5b2e31cb851197ea6"

say()  { echo "$*"; echo "$*" >> "$STATUS"; }
fail() { echo "ERROR: $*" >&2; echo "ERROR: $*" >> "$STATUS"; exit 1; }
cleanup() { [ -n "$MOUNTED" ] && hdiutil detach -quiet "$MOUNTED" >/dev/null 2>&1; true; }
trap cleanup EXIT

# Case-insensitive child lookup: the CD is upper case, copies are often lower.
child() { ls "$1" 2>/dev/null | grep -ix "$2" | head -1; }

is_install_dir() { [ -n "$(child "$1" geo)" ] && [ -n "$(child "$1" cities)" ]; }

find_install_dir() {
    local base="$1" d
    for d in "$base" "$base"/*; do
        [ -d "$d" ] && is_install_dir "$d" && { echo "$d"; return 0; }
    done
    return 1
}

# ---- 1. Locate the original game -------------------------------------------------------------
SRC="${1:-}"
if [ -z "$SRC" ]; then
    for v in /Volumes/*; do
        if found=$(find_install_dir "$v"); then SRC="$found"; break; fi
    done
fi
[ -n "$SRC" ] || fail "No SimCopter CD found. Insert the CD or choose the ISO or folder."

if [ -f "$SRC" ]; then
    say "Opening disc image..."
    MOUNTED=$(hdiutil attach -readonly -nobrowse -noautoopen "$SRC" 2>/dev/null | awk -F'\t' '/\/Volumes\//{print $NF}' | tail -1)
    [ -n "$MOUNTED" ] || fail "Could not open the disc image: $SRC"
    SRC="$MOUNTED"
fi
INSTALL=$(find_install_dir "$SRC") || fail "That doesn't look like SimCopter: no geo and cities folders in $SRC"

# ---- 2. Copy the data ------------------------------------------------------------------------
say "Copying SimCopter game files..."
mkdir -p "$DEST" || fail "Cannot create $DEST"
for name in bmp cities geo sound tweak x smk fonts help; do
    match=$(child "$INSTALL" "$name")
    [ -n "$match" ] || continue
    rsync -a "$INSTALL/$match/" "$DEST/$name/" || fail "Copying $match failed"
done
chmod -R u+w "$DEST"
is_install_dir "$DEST" || fail "The copy is incomplete."

# ---- 3. Find or fetch ffmpeg -----------------------------------------------------------------
FFMPEG=""; FFPROBE=""
for dir in "$FFDIR" /opt/homebrew/bin /usr/local/bin $(echo "$PATH" | tr ':' ' '); do
    if [ -x "$dir/ffmpeg" ] && [ -x "$dir/ffprobe" ] && "$dir/ffmpeg" -hide_banner -encoders 2>/dev/null | grep -q libx264; then
        FFMPEG="$dir/ffmpeg"; FFPROBE="$dir/ffprobe"; break
    fi
done

if [ -z "$FFMPEG" ]; then
    say "Downloading ffmpeg to convert the movies..."
    TMP=$(mktemp -d)
    ok=1
    for tool in ffmpeg ffprobe; do
        want_var="FF_SHA_$tool"; want="${!want_var}"
        if ! curl -sSfL --retry 2 -o "$TMP/$tool.zip" "$FF_BASE/$tool.zip"; then ok=0; break; fi
        got=$(shasum -a 256 "$TMP/$tool.zip" | cut -d' ' -f1)
        if [ "$got" != "$want" ]; then echo "Checksum mismatch for $tool.zip" >&2; ok=0; break; fi
        unzip -oq "$TMP/$tool.zip" -d "$TMP/out" || { ok=0; break; }
    done
    if [ "$ok" = 1 ] && [ -f "$TMP/out/ffmpeg" ] && [ -f "$TMP/out/ffprobe" ]; then
        mkdir -p "$FFDIR"
        mv -f "$TMP/out/ffmpeg" "$TMP/out/ffprobe" "$FFDIR/"
        chmod +x "$FFDIR/ffmpeg" "$FFDIR/ffprobe"
        xattr -d com.apple.quarantine "$FFDIR/ffmpeg" "$FFDIR/ffprobe" 2>/dev/null
        FFMPEG="$FFDIR/ffmpeg"; FFPROBE="$FFDIR/ffprobe"
    fi
    rm -rf "$TMP"
fi

# ---- 4. Convert the movies -------------------------------------------------------------------
frames() { "$FFPROBE" -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of csv=p=0 "$1" 2>/dev/null; }

# convert <source smk name> <output> <expected frames> <ffmpeg output args...>
convert() {
    local name="$1" out="$2" want="$3"; shift 3
    local smk; smk=$(child "$DEST/smk" "$name")
    [ -n "$smk" ] || { echo "Missing $name; skipped." >&2; return 1; }
    mkdir -p "$(dirname "$out")"
    local tmp="${out%.*}.tmp.${out##*.}"
    if "$FFMPEG" -hide_banner -loglevel error -y -i "$DEST/smk/$smk" "$@" "$tmp" &&
       { [ "$want" = 0 ] || [ "$(frames "$tmp")" = "$want" ]; }; then
        mv -f "$tmp" "$out"
    else
        rm -f "$tmp"; echo "Converting $name failed; skipped." >&2; return 1
    fi
}

H264=(-c:v libx264 -preset slow -crf 10 -pix_fmt yuv420p -movflags +faststart)
MOVIES_OK=0
if [ -n "$FFMPEG" ]; then
    MOVIES_OK=1
    say "Converting intro movies..."
    convert intro1.smk "$GEN/Movies/Intro/INTRO1.mp4" 202 -map 0:v:0 -an "${H264[@]}" || MOVIES_OK=0
    convert intro2.smk "$GEN/Movies/Intro/INTRO2.mp4" 838 -map 0:v:0 -map 0:a? "${H264[@]}" -c:a aac -b:a 192k -ar 44100 || MOVIES_OK=0
    say "Converting loading animation..."
    convert hrglass.smk "$GEN/Loading/HRGLASS.png" 0 -vf tile=10x8:nb_frames=75 -frames:v 1 || MOVIES_OK=0
    say "Converting menu sky..."
    convert menusky.smk "$GEN/Movies/MENUSKY.mp4" 201 -map 0:v:0 -an "${H264[@]}" || MOVIES_OK=0
    for city in $(seq 0 29); do
        say "Converting career city previews ($((city + 1)) of 30)..."
        convert "city${city}_s.smk" "$GEN/Movies/Career/CITY${city}_S.mp4" 75 -map 0:v:0 -an "${H264[@]}" || MOVIES_OK=0
    done
fi

if [ "$MOVIES_OK" = 1 ]; then
    say "DONE"
else
    say "DONE_NO_MOVIES"
fi
