extends MarginContainer

export (NodePath) var first_focus_path
onready var first_focus = get_node(first_focus_path) if first_focus_path else null
export (NodePath) var menu_parent_path
onready var menu_parent = get_node(menu_parent_path) if menu_parent_path else null

const fade_transition = false

const debug_mode_inputs = [
	2, 1, 3, 0, # D L R U
	2, 3, 0, 1, # D R U L
	1, 0, 2, 3, # L U D R
	0, 1, 2, 3, # U L D R
	2, 0, 1, 3  # D U L R
]
var debug_mode_input_index = 0

func set_initial_focus():
	first_focus.grab_focus()

func activate_debug_mode():
	print("Debug mode has been activated")
	Global.debug_mode = true

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		var debug_mode_current_input = -1
		if Input.is_action_just_pressed("ui_up"):
			debug_mode_current_input = 0
		elif Input.is_action_just_pressed("ui_left"):
			debug_mode_current_input = 1
		elif Input.is_action_just_pressed("ui_down"):
			debug_mode_current_input = 2
		elif Input.is_action_just_pressed("ui_right"):
			debug_mode_current_input = 3
		elif Input.is_action_just_pressed("ui_accept"):
			debug_mode_current_input = 4
		if debug_mode_current_input >= 0:
			if debug_mode_current_input == debug_mode_inputs[debug_mode_input_index]:
				debug_mode_input_index += 1
				if debug_mode_input_index >= len(debug_mode_inputs):
					activate_debug_mode()
					debug_mode_input_index = 0
			else:
				debug_mode_input_index = 0
	else:
		debug_mode_input_index = 0
