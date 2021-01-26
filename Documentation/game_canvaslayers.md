# List of all CanvasLayers used in the game
| Layer # | Scene file | CanvasLayer name | Use |
|---------|------------|------------------|-----|
| any negative value | [any] | [parallax layers] | Not explicitly defined, but negative values are used by parallax layers in order to put them in the BG behind the main game. |
| 0 | [any] | [most of them] | All things that aren't explicitly on another layer are on layer 0. This includes all of the ingame level stuff, the title screen, etc. |
| 5 | Menus/InGameMenu/InGameMenu.tscn | InGameMenuLayer | Layer used for showing the in-game menu on top of the game itself. |
| 7 | Global/HUDLayer.tscn | HUDLayer | Layer used for showing the HUD on top of the game elements and the in-game menu. |
| 8 | Menus/InGameMenu/InGameMenu.tscn | FadeToBlackLayer | Layer used for showing the in-game menu's fade to black on top of the menu and the HUD. |
| 10 | Global/Global.tscn | SideSwipeAnimationLayer | Layer used for showing the "side swipe" fade in/out animation. Everything else should have a layer # below 10. |
| 100 | Global/Global.tscn | DebugModeTextLayer | Layer used for showing "DEBUG MODE ACTIVE" text on top of everything else, and at all times. |
