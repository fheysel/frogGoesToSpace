extends MarginContainer

var inhibit_pause = true
var inhibit_hud = true

onready var BGMPlayer := $Level1BacktrackPlayer

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		Global.fade_to_scene(Global.main_menu_path)
