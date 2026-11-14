SimCopter Remake for Mac (Apple Silicon)
========================================

This is an unofficial Apple Silicon build of SimCopter Remake
(https://github.com/JamesIV4/sim-copter-remake), using the Mac port from
https://github.com/wyozi/sim-copter-remake.

It does NOT include any of the original SimCopter (1996) game files. You need
your own copy of the original game: the CD, an ISO image of it, or an
installed SimCopter folder.

Setup
-----

1. Insert or mount your SimCopter CD, or have the ISO or folder ready.

2. Open "Install SimCopter Data". It finds the CD by itself, or lets you
   pick the ISO or folder, then copies the game files and converts the
   original movies. Nothing else needs to be installed first: if needed it
   downloads ffmpeg (the movie converter) by itself.

3. Open SimCopterRemake.

The first time you open each app
--------------------------------

These apps are not notarized by Apple, so macOS blocks them the first time:

  - Double-click the app. When macOS says it can't be opened, click Done.
  - Open System Settings > Privacy & Security, scroll down, and click
    "Open Anyway" next to the app's name. Confirm with your password.

You only need to do this once per app. The game's first launch can sit on a
black window for a few minutes while macOS scans it; that also happens once.

Where things go
---------------

  ~/Library/Application Support/SimCopterRemake/SimCopter   your game files
  ~/Library/Application Support/SimCopterRemake/ffmpeg      downloaded ffmpeg

Delete that SimCopterRemake folder to remove everything.
