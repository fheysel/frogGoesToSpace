extends MarginContainer

var inhibit_pause = true

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		Global.fade_to_scene('res://Level0.tscn')
