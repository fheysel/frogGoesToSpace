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
