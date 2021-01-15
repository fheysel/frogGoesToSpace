extends MarginContainer

export (NodePath) var first_focus_path
onready var first_focus = get_node(first_focus_path)
export (NodePath) var menu_parent_path
onready var menu_parent = get_node(menu_parent_path)

const fade_transition = false

func set_initial_focus():
	first_focus.grab_focus()
