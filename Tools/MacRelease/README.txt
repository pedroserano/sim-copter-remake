SimCopter Remake for Mac (Apple Silicon)
========================================

This is an unofficial Apple Silicon build of SimCopter Remake
(https://github.com/JamesIV4/sim-copter-remake), using the Mac port from
https://github.com/wyozi/sim-copter-remake.

It does NOT include any of the original SimCopter (1996) game files. You need
your own copy of the original game: the CD, an ISO image of it, or an
installed SimCopter folder.

1. Insert or mount your SimCopter CD (or have the ISO / folder ready).

2. Optional, for the intro movies and animated menus:
       brew install ffmpeg
   Without ffmpeg the game still runs; those movies are skipped.

3. Double-click "Install SimCopter Data.command".
   If macOS refuses to open it, right-click it and choose Open.
   It copies the game data to:
       ~/Library/Application Support/SimCopterRemake/SimCopter
   You can also pass the location yourself:
       ./"Install SimCopter Data.command" /path/to/SimCopter.iso

4. Open SimCopterRemake.app. The app is not notarized, so the first time
   macOS will block it. Either right-click it and choose Open, or run:
       xattr -dr com.apple.quarantine SimCopterRemake.app

The first launch can sit on a black window for a few minutes while macOS
scans the app. That only happens once.
