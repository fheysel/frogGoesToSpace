extends Node

export (bool) var debug_mode = false
export (bool) var player_is_god = false

export (float) var game_audio_volume_fadeout = 1

const main_menu_path = "res://Menus/MainMenu/MainMenu.tscn"

var resource_queue = preload("res://Global/ResourceQueue.gd").new()
var loading = null
var swipe_anim_state_machine = null
var pause_during_transition = false
var cutscene_pauses_game = false
var cutscene_inhibits_pause = false

onready var HighScoreScreen := $HighScoreScreenLayer/HighScoreScreen
onready var InGameMenu := $InGameMenuLayer/InGameMenu

# This pause is applied in Global.gd (this script)
# This refers to setting get_tree().paused
func should_pause_game():
	return \
		loading != null || \
		cutscene_pauses_game || \
		pause_during_transition || \
		InGameMenu.active() || \
		HighScoreScreen.active()

# This hiding is applied in HUDRoot.gd
func should_hide_hud():
	return \
		current_scene_has_property_set('inhibit_hud') || \
		InGameMenu.should_hide_hud() || \
		HighScoreScreen.active()

# This inhibiting is checked in the InGameMenu.gd
func should_inhibit_pause_menu():
	return \
		cutscene_inhibits_pause ||\
		current_scene_has_property_set("inhibit_pause") || \
		HighScoreScreen.active()

func _ready():
	resource_queue.start()
	swipe_anim_state_machine = $SideSwipeAnimationLayer/AnimationTree['parameters/playback']
	swipe_anim_state_machine.start('idle')

func _process(_delta_unused):
	var pause_game_logic = should_pause_game()
	get_tree().paused = pause_game_logic
	# Get game audio object for current scene
	var scene = get_tree().current_scene
	if scene and 'BGMPlayer' in scene:
		var music : AudioStreamPlayer = scene.BGMPlayer
		if music:
			# Only calculate and update volume if it's not going to cause a
			# division by zero
			if game_audio_volume_fadeout > 0.001:
				var db = 1 - 6 - 1/pow(game_audio_volume_fadeout,2)
				music.volume_db = db
	$DebugModeTextLayer/DebugModeText.visible = debug_mode
	# Handle debug mode button combinations
	if debug_mode:
		if Input.is_action_pressed("menu") && Input.is_action_pressed("ui_accept"):
			if Input.is_action_just_pressed("ui_up"):
				# Enable god mode on the player
				player_is_god = !player_is_god
				print("Player is god: ", player_is_god)
			if Input.is_action_just_pressed("ui_down"):
				# Exit game - used to power off arcade machine
				get_tree().quit(2)

func _load_bg(scene_path):
	resource_queue.queue_resource(scene_path, true)
	loading = scene_path

func fade_to_scene(scene_path):
	if scene_path == null:
		# Uh oh. An error has occurred. Go to title screen.
		scene_path = main_menu_path
	if loading == null:
		# Load the next scene in the background ASAP
		_load_bg(scene_path)

		# Fade to loading screen
		swipe_anim_state_machine.travel('swipe_in')

		# Pause the game while we transition
		pause_during_transition = true

func _process_loading():
	if resource_queue.is_ready(loading):
		# We've finished loading the resource!
		# Prepare all the misc. other objects to be ready for this new scene.

		# Reset the global timer
		$"/root/CountupTimer".reset()

		# Close the pause menu, if it was open
		$InGameMenuLayer/InGameMenu.navigate_to_new_screen(null)

		# Close the high-score screen, if it was open
		HighScoreScreen.close()
		
		# Any cutscene that was playing is now over, or will be taken over by the new object.
		# If you need to adjust these values, make sure you do it in the _enter_tree function.
		cutscene_pauses_game = false
		cutscene_inhibits_pause = false

		# Change to the new scene
		if get_tree().change_scene_to(resource_queue.get_resource(loading)) != OK:
			# If we couldn't go to the new level, exit :(
			push_error("Unable to load level")
			get_tree().quit(1)

		# Fade in
		swipe_anim_state_machine.travel('swipe_out')

		# Mark that we're done loading
		loading = null


func _unpause_new_scene():
	# We're now in the new scene. Unpause :)
	pause_during_transition = false

### Helper functions
# Check if the current scene (as marked during the transition)
# has a given property set to true. Used to check if we are allowed
# to pause or if we should show the HUD.
func current_scene_has_property_set(property):
	var scene = get_tree().current_scene
	if !scene:
		return false
	return property in scene and scene[property]

# Similar to the above, get the property value.
func get_current_scene_property(property):
	var scene = get_tree().current_scene
	if !scene or !(property in scene):
		return null
	return scene[property]

# Format a number of seconds (with possible floating point parts)
# into a string.
func format_time(time):
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	var subseconds = int(time * 60) % 60
	return "%01d:%02d:%02d" % [minutes, seconds, subseconds]
