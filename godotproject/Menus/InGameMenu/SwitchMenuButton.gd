extends Button

export (NodePath) var menu_control_path
onready var menu_control = get_node(menu_control_path) if menu_control_path else null
export (NodePath) var target_path
onready var target = get_node(target_path) if target_path else null

func _on_pressed():
	menu_control.navigate_to_new_screen(target)
