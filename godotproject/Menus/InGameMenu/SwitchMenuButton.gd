extends Button

export (NodePath) var menu_control_path
onready var menu_control : Node = get_node(menu_control_path) if menu_control_path else null
export (NodePath) var target_path
onready var target : Node = get_node(target_path) if target_path else null

func _on_pressed():
	if menu_control and menu_control.has_method('navigate_to_new_screen'):
		menu_control.navigate_to_new_screen(target)
	else:
		printerr('Invalid menu control path ', menu_control_path, ' for menu button ', get_path())
