extends Node

export (bool) var debug_mode = false
export (bool) var player_is_god = false

export (float) var game_audio_volume_fadeout = 1

const main_menu_path = "res://Menus/MainMenu/MainMenu.tscn"

enum FadeAction { LOAD_SCENE, MOVE_POSITION }

var fade_action = null
var fade_action_body = null
var fade_action_position = null

var resource_queue = preload("res://Global/ResourceQueue.gd").new()
var loading = null
var swipe_anim_state_machine = null
var pause_during_transition = false
var cutscene_pauses_game = false
var cutscene_inhibits_pause = false

onready var HighScoreScreen := $HighScoreScreenLayer/HighScoreScreen
onready var InGameMenu := $InGameMenuLayer/InGameMenu

onready var music_bus_idx := AudioServer.get_bus_index("Music")
onready var sfx_bus_idx := AudioServer.get_bus_index("Sfx")
### Used during gameplay
# Music volume, from 0 (silent) to 1 (loud)
var music_volume = 0
# Sound effect volume, from 0 (silent) to 1 (loud)
var sfx_volume = 0
### Used during title screen
# Title screen volume, from 0 (silent) to 1 (loud)
# This is the initial volume for the game!
var title_volume = 0.2
### Used to transition volume state between the two
var on_title_screen_last_frame = true

#Game Difficulty Level:
#Easy: Colliding with enemies does not do any damage to the player unless they are attacking

enum DIFFICULTY {
	EASY_MODE_e,
	HARD_MODE_e,
}

var difficulty = DIFFICULTY.EASY_MODE_e

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

# This is checked in the CountUpDownTimer module
func level_uses_countdown_timer():
	return \
		current_scene_has_property_set("use_countdown_timer")

# Calculate the volume in dB for a bus, given the base volume and
# any fading volume.
func _calc_bus_db(base_volume : float, fade_volume : float):
	var combined := base_volume * pow(fade_volume, 2)
	var db := linear2db(combined)
	return db

func _handle_volumes(on_title_screen):
	if on_title_screen and not on_title_screen_last_frame:
		# Transition from game to title
		# Take the min of volumes
		title_volume = min(music_volume, sfx_volume)
		get_tree().call_group("TitleVolumeSlider", "get_global_volume")
	elif not on_title_screen and on_title_screen_last_frame:
		# Transition from title to game
		music_volume = title_volume
		sfx_volume = title_volume
		get_tree().call_group("InGameVolumeSliders", "get_global_volume")
	on_title_screen_last_frame = on_title_screen
	var music_vdb
	var sfx_vdb
	if on_title_screen:
		music_vdb = _calc_bus_db(title_volume, 1)
		sfx_vdb   = _calc_bus_db(title_volume, 1)
	else:
		music_vdb = _calc_bus_db(music_volume, game_audio_volume_fadeout)
		sfx_vdb   = _calc_bus_db(sfx_volume, 1)
	AudioServer.set_bus_volume_db(music_bus_idx, music_vdb)
	AudioServer.set_bus_volume_db(sfx_bus_idx, sfx_vdb)

func _update_volumes():
	get_tree().call_group("TitleVolumeSlider", "get_global_volume")
	get_tree().call_group("InGameVolumeSliders", "get_global_volume")

func _ready():
	resource_queue.start()
	swipe_anim_state_machine = $SideSwipeAnimationLayer/AnimationTree['parameters/playback']
	swipe_anim_state_machine.start('idle')
	call_deferred("_update_volumes")

func _process(_delta_unused):
	var pause_game_logic = should_pause_game()
	get_tree().paused = pause_game_logic
	# Adjust music bus volume
	_handle_volumes(current_scene_has_property_set('is_title_screen'))
	# Show debug mode text if we're in debug mode
	$DebugModeTextLayer/DebugModeText.visible = debug_mode
	# Handle debug mode button combinations
	if debug_mode:
		if Input.is_action_pressed("menu") && Input.is_action_pressed("ui_accept"):
			if Input.is_action_just_pressed("ui_up"):
				# Enable god mode on the player
				player_is_god = !player_is_god
				print("Player is god: ", player_is_god)
			if Input.is_action_just_pressed("ui_left"):
				# Exit game - used to exit to desktop for troubleshooting
				get_tree().quit(0)
			if Input.is_action_just_pressed("ui_down"):
				# Exit game - used to power off arcade machine
				get_tree().quit(2)
			if Input.is_action_just_pressed("ui_right"):
				# Clear high scores
				var dir = Directory.new()
				dir.remove("user://scores.json")
				print("High scores deleted.")

func _load_bg(scene_path):
	resource_queue.queue_resource(scene_path, true)
	loading = scene_path

func fade_to_scene(scene_path):
	if scene_path == null:
		# Uh oh. An error has occurred. Go to title screen.
		scene_path = main_menu_path
	if loading == null:
		# Set fade action so that it's kept track of properly
		fade_action = FadeAction.LOAD_SCENE

		# Load the next scene in the background ASAP
		_load_bg(scene_path)

		# Fade to loading screen
		swipe_anim_state_machine.travel('swipe_in')

		# Pause the game while we transition
		pause_during_transition = true

func fade_set_body_to_position(body, position):
	# Set up variables to move body properly
	fade_action = FadeAction.MOVE_POSITION
	fade_action_body = body
	fade_action_position = position

	# Fade to loading screen
	swipe_anim_state_machine.travel('swipe_in')

	# Pause the game while we transition
	pause_during_transition = true

func _step_loading():
	# We don't actually care if it's ready, we just want to load a piece.
	var _ready = resource_queue.is_ready(loading)

func _process_loading():
	if loading == null and fade_action == FadeAction.MOVE_POSITION:
		# Move body's position to the specified location
		fade_action_body.position = fade_action_position
		# Fade in
		swipe_anim_state_machine.travel('swipe_out')
	elif resource_queue.is_ready(loading):
		# We've finished loading the resource!
		# Prepare all the misc. other objects to be ready for this new scene.

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

		# Handle events that must be processed after we have switched to the new scene
		call_deferred("_after_loading_new_scene")

		# Fade in
		swipe_anim_state_machine.travel('swipe_out')

		# Mark that we're done loading
		loading = null

func _after_loading_new_scene():
	# Reset the global timer after switching scene
	# Must be after changing to scene to set counting up/down!
	var new_scene_countdown = current_scene_has_property_set('use_countdown_timer')
	var new_scene_countdown_val = get_current_scene_property('countdown_timer_initial_count')
	$"/root/CountUpDownTimer".reset(new_scene_countdown, new_scene_countdown_val)


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

# Check if a given body is the player. Useful for scripts where
# we only want to interact with the player.
func is_player(body):
	return body.name == "Player"

# Get player object. Used by countdown timer to kill the player when they run out of time.
# Returns null if player couldn't be found.
func get_player():
	return get_tree().current_scene.get_node_or_null("Player")

# Check if a node exists and is inside the tree. Used to track if we have
# Based on: https://godotengine.org/qa/37579/need-an-easy-way-to-check-which-ones-are-still-in-the-scene-tree
func node_exists_in_tree(node):
	return node != null and \
		is_instance_valid(node) and \
		node is Node and \
		node.is_inside_tree()

# Function to set volume level on both volume sliders.
# Used on title screen to adjust volume.
func set_volume(volume):
	get_tree().call_group("VolumeSliders","set_volume",volume)
