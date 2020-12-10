# Exporting FGTS to HTML5

The FGTS game can be exported to HTML5 by following these steps:
1. Ensure you have the `FrogGoesToSpace.github.io` **repository** (henceforth, Github Pages repo) cloned and up-to-date.
1. In the Github Pages repo, delete all files under the `godotproject-export` directory.
1. Get latest files in `frogGoesToSpace` repository. (`git checkout main && git pull`)
1. Open project in Godot
1. Go Project -> Export...
1. Select the HTML5 preset and click "Export Project"
1. Navigate to the now-empty `godotproject-export` subdirectory in the Github Pages repo, and name the file `game.html`.
1. Click Save.
    - This will export the Godot project to HTML5
1. In the Github Pages repo, do `git add godotproject-export` to pick up the new files.
1. Commit and push the new changes in the Github Pages Repo.
1. The webpage should update and the latest version should be live! (it may take a minute)

# Exporting FGTS to Pi

On the Raspberry Pi, the game is stored in the `/boot/fgts-pi` directory and split in two parts:
- the executable file (`game`)
- the packed data file (`game.pck`)

The game files are stored under the `/boot/fgts-pi` directory so that the SD card can be easily
removed and updated with new game files - when the SD card is inserted into a Windows computer,
only the files under `/boot` will be visible.

The executable file was compiled from source on an external drive using the Pi.
Please DO NOT overwrite the `game` file unless absolutely necessary.
There is no data specific to FGTS in the `game` executable file.
All data is read from the packed data file.

The packed data file can be generated from Godot using the following process:
1. Get latest files in `frogGoesToSpace` repository. (`git checkout main && git pull`)
1. Open project in Godot
1. Go Project -> Export...
1. Select the Linux/X11 preset and click "Export PCK/Zip"
1. Navigate to any directory (ex. Desktop) and export `game.pck`
1. Power off the arcade machine
1. Remove the SD card and insert into computer
1. Copy `game.pck` to `(SD card):/fgts-pi/game.pck`, replacing the previous `.pck` file
1. Eject SD card and return to arcade machine
1. Power on the arcade machine
1. The new version of the game should run automatically on startup!
