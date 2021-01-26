extends Node

export (bool) var debug_mode = false
export (bool) var player_is_god = false

const main_menu_path = "res://Menus/MainMenu/MainMenu.tscn"

var resource_queue = preload("res://Global/ResourceQueue.gd").new()
var loading = null
var swipe_anim_state_machine = null
var unpause_scene_upon_idle = false

func _ready():
	resource_queue.start()
	swipe_anim_state_machine = $SideSwipeAnimationLayer/AnimationTree['parameters/playback']
	swipe_anim_state_machine.start('idle')

func _process(_delta_unused):
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
	if loading == null:
		# Load the next scene in the background ASAP
		_load_bg(scene_path)

		# Once processing is done, fade to the new scene
		call_deferred('_fade_to_scene_deferred')

func _fade_to_scene_deferred():
	# Disable the current scene
	get_tree().get_current_scene().pause_mode = PAUSE_MODE_STOP

	# Fade to loading screen
	swipe_anim_state_machine.travel('swipe_in')

func _process_loading():
	if resource_queue.is_ready(loading):
		# We've finished loading the resource!

		# Change to the new scene
		if get_tree().change_scene_to(resource_queue.get_resource(loading)) != OK:
			# If we couldn't go to the new level, exit :(
			push_error("Unable to load level")
			get_tree().quit(1)

		# Set it paused while we fade in
		call_deferred('_pause_new_scene_deferred')
		# Make sure we unpause once we fade in
		unpause_scene_upon_idle = true

		# Reset the global timer
		$"/root/CountupTimer".reset()

		# Close the pause menu, if it was open
		$InGameMenuLayer/InGameMenu.navigate_to_new_screen(null)

		# Fade in
		swipe_anim_state_machine.travel('swipe_out')

		# Mark that we're done loading
		loading = null

func _pause_new_scene_deferred():
	get_tree().paused = true

func _unpause_new_scene():
	if unpause_scene_upon_idle:
		get_tree().paused = false
		unpause_scene_upon_idle = false

### Helper functions
# Check if the current scene (as marked during the transition)
# has a given property set to true. Used to check if we are allowed
# to pause or if we should show the HUD.
func current_scene_has_property_set(property):
	var scene = get_tree().current_scene
	if !scene:
		return false
	return property in scene and scene[property]

