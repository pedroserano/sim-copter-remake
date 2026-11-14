-- "Install SimCopter Data.app": a double-click front end for install.sh (in Contents/Resources).
-- Finds the SimCopter CD, or asks for the ISO or folder, then shows a progress bar while the
-- script copies the data and converts the movies. Built by Tools/MacRelease/make_release.sh.

on run
	set appName to "Install SimCopter Data"
	set scriptPath to POSIX path of (path to resource "install.sh")

	-- Use an inserted or mounted SimCopter CD if there is one; otherwise ask.
	set sourcePath to ""
	set cdFound to do shell script "for v in /Volumes/*; do for d in \"$v\" \"$v\"/*; do [ -d \"$d\" ] || continue; ls \"$d\" | grep -qix geo && ls \"$d\" | grep -qix cities && { echo \"$d\"; exit 0; }; done; done; true"
	if cdFound is not "" then
		set answer to button returned of (display dialog "Found SimCopter at:" & return & cdFound & return & return & "Install the game files from there?" buttons {"Choose Another…", "Install"} default button "Install" with title appName with icon note)
		if answer is "Install" then set sourcePath to cdFound
	end if

	if sourcePath is "" then
		set answer to button returned of (display dialog "SimCopter Remake needs the files from your own SimCopter CD." & return & return & "Choose your SimCopter disc image (.iso), or the CD / installed SimCopter folder." buttons {"Cancel", "Choose Folder…", "Choose Disc Image…"} default button "Choose Disc Image…" cancel button "Cancel" with title appName with icon note)
		if answer is "Choose Disc Image…" then
			set sourcePath to POSIX path of (choose file with prompt "Choose your SimCopter disc image")
		else
			set sourcePath to POSIX path of (choose folder with prompt "Choose your SimCopter CD or install folder")
		end if
	end if

	set statusFile to do shell script "mktemp -t simcopter-install"
	set logFile to statusFile & ".log"
	set pid to do shell script "SIMCOPTER_STATUS=" & quoted form of statusFile & " /bin/bash " & quoted form of scriptPath & " " & quoted form of sourcePath & " > " & quoted form of logFile & " 2>&1 & echo $!"

	-- 4 copy/download steps + 4 movie steps + 30 career previews.
	set progress total steps to 38
	set progress completed steps to 0
	set progress description to "Installing SimCopter game files"
	set lastLine to ""
	repeat
		delay 0.5
		set lastLine to do shell script "tail -n 1 " & quoted form of statusFile & " 2>/dev/null; true"
		set stepCount to (do shell script "wc -l < " & quoted form of statusFile & " | tr -d ' '") as integer
		if stepCount > 38 then set stepCount to 38
		set progress completed steps to stepCount
		if lastLine is not "" then set progress additional description to lastLine
		set running to do shell script "kill -0 " & pid & " 2>/dev/null && echo yes || echo no"
		if running is "no" then exit repeat
	end repeat
	set lastLine to do shell script "tail -n 1 " & quoted form of statusFile & " 2>/dev/null; true"

	if lastLine is "DONE" then
		display dialog "SimCopter is installed. You can now open SimCopterRemake.app." buttons {"OK"} default button "OK" with title appName with icon note
	else if lastLine is "DONE_NO_MOVIES" then
		display dialog "The SimCopter game files are installed and the game is ready to play." & return & return & "The intro and menu movies could not be converted (ffmpeg could not be downloaded). The game skips them. Run this installer again later to add them." buttons {"OK"} default button "OK" with title appName with icon caution
	else
		set details to do shell script "tail -n 5 " & quoted form of logFile & " 2>/dev/null; true"
		display dialog "Installation did not finish." & return & return & details buttons {"OK"} default button "OK" with title appName with icon stop
	end if
	do shell script "rm -f " & quoted form of statusFile & " " & quoted form of logFile
end run
