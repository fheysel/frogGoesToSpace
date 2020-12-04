extends Button

export (NodePath) var menu_control_path
onready var menu_control = get_node(menu_control_path)
export (NodePath) var target_path
onready var target = get_node(target_path)

func _on_pressed():
	menu_control.navigate_to_new_screen(target)
