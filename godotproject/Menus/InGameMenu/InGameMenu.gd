extends MarginContainer

export (bool) var pause_child = false
export (NodePath) var default_screen_path
onready var default_screen = get_node(default_screen_path)

func init_screen_list():
	# This is a list of screens in the current menu.
	screens.append($PauseSubmenu)
	screens.append($HelpSubmenu)
	screens.append($QuitVerifySubmenu)

var screens = []
var screen_current = null
var screen_after_fade = null

func _screen_has_property_set(screen, property):
	if !screen:
		return false
	return property in screen and screen[property]

func active():
	return screen_current != null

func should_hide_hud():
	return _screen_has_property_set(screen_current, "hide_hud")

func update_active_screen():
	# Pause and hide all of our child screens
	for screen in screens:
		screen.pause_mode = PAUSE_MODE_STOP
		screen.visible = false
	# If we're trying to display a null screen, we're trying to close the menu
	if screen_current == null:
		# Hide ourselves
		visible = false
	else:
		# Show ourselves (the in-game menu)
		visible = true
		# Set specific screen to be displayed and run
		screen_current.visible = true
		screen_current.pause_mode = PAUSE_MODE_PROCESS

func pause_all_screens():
	for screen in screens:
		screen.pause_mode = PAUSE_MODE_STOP

func _switch_screen(new_screen):
	screen_current = new_screen
	# Make screen visible and unpaused
	update_active_screen()
	# If we're switching to a real screen and not closing
	if screen_current != null:
		# Set focus on default element of screen
		# If we didn't set focus, no element would have focus by default,
		# and we wouldn't be able to use the arrow keys to navigate.
		# Note: focus must be set after visibility is adjusted and
		# object is unpaused, otherwise it won't actually give it focus.
		screen_current.set_initial_focus()
	
func _fade_to_new_screen(new_screen):
	screen_after_fade = new_screen
	$AnimationPlayer.play("fade")

func _screen_should_fade(screen):
	return _screen_has_property_set(screen, "fade_transition")

func navigate_to_new_screen(new_screen):
	if new_screen != null && (_screen_should_fade(screen_current) || _screen_should_fade(new_screen)):
		_fade_to_new_screen(new_screen)
	else:
		_switch_screen(new_screen)
	
func open_menu():
	_switch_screen(default_screen)

func close_menu():
	_switch_screen(null)

func global_main():
	if $AnimationPlayer.is_playing():
		# Bypass executing all menu logic while we switch which screen is displayed
		return
	# Menu logic
	var menu_pressed = Input.is_action_just_pressed("menu")
	if menu_pressed:
		# The menu button should "go back" by one screen
		# Since we only have one layer deep of screens,
		# we just go back to the pause screen, unless we're already there,
		# in which case we close ourselves.
		navigate_to_new_screen(screen_current.menu_parent)

func _ready():
	init_screen_list()
	close_menu()

func _process(_delta):
	var menu_pressed = Input.is_action_just_pressed("menu")
	# We set the screen_current variable to null to indicate that the menu is closed.
	# We need to check if we're allowed to pause the game at this time.
	var inhibit_pause = Global.should_inhibit_pause_menu()
	if !inhibit_pause && menu_pressed && screen_current == null:
		open_menu()
	elif visible:
		global_main()
	
	# Apply our variable pause_child - it will be animated during screen fades
	if screen_current != null:
		screen_current.pause_mode = PAUSE_MODE_STOP if pause_child else PAUSE_MODE_INHERIT

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
		_switch_screen(screen_after_fade)
		$AnimationPlayer.play("unfade")
