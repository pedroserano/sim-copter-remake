# SimCopter Remake for Mac (Apple Silicon)

[![Download for Mac](https://img.shields.io/badge/Download-Mac%20(Apple%20Silicon)-brightgreen?style=for-the-badge&logo=apple)](https://github.com/pedroserano/sim-copter-remake/releases/latest)

> **This is an unofficial Apple Silicon (M1, M2, M3, M4 and later) port of [SimCopter Remake](https://github.com/JamesIV4/sim-copter-remake)** by JamesIV4. It runs natively on Apple Silicon Macs, without Windows, Wine, CrossOver or a virtual machine.
>
> It builds on the Mac port work in [wyozi/sim-copter-remake](https://github.com/wyozi/sim-copter-remake) and adds a **data-free download with a click-to-install setup**. All of the game itself is JamesIV4's work. For the Windows version, go to the [original project](https://github.com/JamesIV4/sim-copter-remake/releases/latest).

## Playing on a Mac

**You need your own copy of the original SimCopter (1996)**: the CD, an ISO image of it, or an installed SimCopter folder. This download contains none of the original game files.

1. **Download** the latest `SimCopterRemake-…-mac-arm64.zip` from [Releases](https://github.com/pedroserano/sim-copter-remake/releases/latest) and unzip it.
2. **Insert or mount your SimCopter CD**, or have the ISO or folder ready.
3. **Open _Install SimCopter Data_.** It finds the CD on its own, or asks you to pick the ISO or folder. Then it copies the game files and converts the original movies while a progress bar shows how far it has got.
4. **Open _SimCopterRemake_** and fly.

You don't need Homebrew, Python, Terminal or an admin password.

**First launch:** the apps aren't notarized by Apple, so macOS blocks each one the first time you open it. Double-click the app, click **Done** on the warning, then go to **System Settings → Privacy & Security** and click **Open Anyway**. You only do this once per app. The game's first start can sit on a black window for a few minutes while macOS scans it, and that also only happens once.

### What this port changes

- **Native Apple Silicon build.** The game is compiled for arm64 and renders with Metal. It includes wyozi's Mac fixes for compiler errors, input (dead mouse clicks, stuck modifier keys), graphics settings tuned for Mac, and Mac packaging.
- **No original game data in the download.** The release script strips the original SimCopter files, and movies converted from them, out of the packaged app. It refuses to create the zip if any original-looking file is left inside the app.
- **Game data lives outside the app.** On Mac the game also looks in `~/Library/Application Support/SimCopterRemake/SimCopter` for the original files and converted movies. You never have to modify the app (which would break its code signature), and your data survives updates.
- **Click-to-install setup app.** _Install SimCopter Data_ is a normal Mac app with dialogs and a progress bar. It finds the CD automatically, accepts an ISO or folder, copies the data, and converts the intro movies, menu sky, career previews and loading animation.
- **ffmpeg handled automatically.** Movie conversion uses ffmpeg. The installer uses one that's already installed. If there isn't one, it downloads a standalone Apple Silicon ffmpeg 9.0.2 build and checks it against the publisher's SHA-256 checksum, without Homebrew or an admin password. If that fails, the game is still installed and just skips those movies.
- **No Python needed.** The movie conversion that used to run through the project's Python scripts is done with plain ffmpeg commands, and each converted movie's frame count is checked.

To remove everything, delete `~/Library/Application Support/SimCopterRemake` and the two apps.

### Building it yourself

See [Docs/memory/mac-build-and-run.md](Docs/memory/mac-build-and-run.md) for building with Unreal Engine 5.8 on a Mac. [Tools/MacRelease/make_release.sh](Tools/MacRelease/make_release.sh) turns a packaged build into the data-free release zip, and [Tools/MacRelease/installer](Tools/MacRelease/installer) holds the installer.

---

## About SimCopter Remake

_The original project's description follows._

**SimCopter Remake** is a ground-up reimplementation of Maxis's 1996 PC game _SimCopter_, built in Unreal Engine 5.

The goal is to recreate the original game as faithfully as possible while making it run properly on modern PCs. It retains the original missions, helicopters, flight behavior, city importing, radio stations, and assorted Sim weirdness, but adds modern rendering, widescreen support, longer view distances, improved controls, and native support for current versions of Windows.

Several _SimCity 2000_ cities, including Cape Wells, Tokyo, and Rio, are included so you can start flying right away. You can also import your own `.sc2` cities and fly around them just as you could in the original game.

## Screenshots

|                    Flight & City Exploration                     |                      Firefighting Operations                      |
| :--------------------------------------------------------------: | :---------------------------------------------------------------: |
| [![City Flight](Docs/screenshots/1.png)](Docs/screenshots/1.png) | [![Firefighting](Docs/screenshots/2.png)](Docs/screenshots/2.png) |

|                     Maritime Rescue Operations                     |                        Winch & Passenger Pickup                         |
| :----------------------------------------------------------------: | :---------------------------------------------------------------------: |
| [![Sunset Rescue](Docs/screenshots/3.png)](Docs/screenshots/3.png) | [![Rescuing Survivors](Docs/screenshots/4.png)](Docs/screenshots/4.png) |

|                        Cockpit Camera View                         |                   Night Flight & City Skyline                   |
| :----------------------------------------------------------------: | :-------------------------------------------------------------: |
| [![Rescue Camera](Docs/screenshots/5.png)](Docs/screenshots/5.png) | [![Night City](Docs/screenshots/6.png)](Docs/screenshots/6.png) |

## Recreating the Original Game

A lot of the work on SimCopter Remake has gone into reproducing how the original game actually behaved rather than simply making a new helicopter game that looks similar.

- **SimCity 2000 cities:** Play the original 30 career cities, load included sandbox cities such as Cape Wells, Egypt Falls, Tokyo, and Rio, or import your own `.sc2` files from _SimCity 2000_. Terrain, water, roads, bridges, and buildings are converted into a flyable 3D city.

- **Original helicopter fleet:** The full helicopter progression returns, starting with the Schweizer 300 and continuing through the Bell 206 JetRanger, MD 500, MBB Bo 105, Eurocopter AS365 Dauphin, and Boeing CH-47 Chinook. Flight and landing behavior are based on the parameters and rules used by the original game.

- **Missions and career progression:** Emergency calls appear throughout the city and completing them earns money and points. Missions include transporting passengers, evacuating medical patients, fighting fires, rescuing people from rooftops and the water, clearing traffic jams, breaking up riots, and helping police apprehend criminals.

- **SimCopter's strange little world:** The remake also keeps the less serious parts of the game: blocky Sims waving frantically from rooftops, pedestrians ending up where they probably shouldn't, and the occasionally questionable logic of 1990s Sim AI.

- **Cockpit equipment:** The searchlight, megaphone, water bucket, rescue harness, water cannon, and tear gas all return, along with the familiar radar, fuel gauge, altimeter, speedometer, and passenger display.

- **Radio stations:** The original Rock, Classical, Jazz, Techno, and Mix stations are supported, including the music, DJs, and wonderfully odd commercials that played while you flew around the city.

## Modern Improvements

The underlying game is intentionally kept close to the original, but a number of things have been updated where the limitations of a 1996 PC game don't need to be preserved.

- **Modern rendering:** Cities now have a dynamic day/night cycle, nighttime lighting, shadows, reflections, and modern indirect lighting through Unreal Engine 5.8.

- **Higher resolutions and frame rates:** The game supports modern resolutions including 1080p, 1440p, 4K, and ultrawide displays, with frame rates no longer tied to the limitations of the original game.

- **Keyboard, mouse, and controller support:** Controls have been adapted for modern keyboard/mouse setups as well as Xbox, PlayStation, and other dual-stick controllers, with configurable flight inputs.

- **Native modern Windows support:** The remake is a 64-bit application designed to run directly on current Windows systems rather than relying on compatibility modes, wrappers, or emulation.

- **Longer view distance:** The extremely aggressive distance fog of the original game is no longer necessary. You can climb above the city and actually see much more of it beneath you.

## How It Was Made

SimCopter Remake was built through a combination of **decompilation, analysis, and reimplementation of the original game**.

Instead of trying to recreate SimCopter's behavior by eye, I analyzed the original executable and game data to understand how its systems worked. That includes things such as helicopter parameters, flight calculations, building generation, mission logic, controls, and the formats used by the game's assets and city data.

Those systems have then been reimplemented in Unreal Engine rather than simply wrapping or modifying the original executable.

That approach matters because SimCopter has a very particular feel. Some of it is intentional, some of it is probably the result of how a PC game was written in 1996, and some of it is just strange. I wanted to preserve that rather than "fixing" the game until it no longer felt like SimCopter.

The result is intended to behave like the game I remember playing in 1996, just without needing a 1996 computer to enjoy it.
