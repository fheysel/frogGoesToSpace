# Save file information
To save high score information, the scores are persisted to a .JSON file (see `godotproject\Menus\HighScoreScreen\HighScoreScreen.gd` for more information).

This file is saved as `user://scores.json`, and a custom user directory of `fgts-data` is set in the Godot project settings.

On the Pi, the path will be
`/home/pi/.local/share/fgts-data/scores.json`

On Windows, the path will be
`%APPDATA%\fgts-data\scores.json`
