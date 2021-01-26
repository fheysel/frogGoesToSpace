extends MarginContainer

export (NodePath) var first_focus_path
onready var first_focus : Node = get_node(first_focus_path) if first_focus_path else null
export (NodePath) var menu_parent_path
onready var menu_parent : Node = get_node(menu_parent_path) if menu_parent_path else null

const fade_transition = true
const hide_hud = true

func set_initial_focus():
	if first_focus and first_focus.has_method('grab_focus'):
		first_focus.grab_focus()
	else:
		printerr('Invalid first focus path ', first_focus_path, ' for menu ', get_path())
