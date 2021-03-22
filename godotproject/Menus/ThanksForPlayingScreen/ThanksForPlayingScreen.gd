extends MarginContainer

var inhibit_pause = true
var inhibit_hud = true
var start = true
var scroll_speed = 0.5

func _process(_delta):
	if(start == true):
		start = false
		$VBoxContainer2.rect_position.y = 500
		self.margin_top = 0
		
	if($VBoxContainer2.rect_position.y <= -120):
		scroll_speed = 0
		
	$VBoxContainer2.rect_position.y -= scroll_speed
	
	if Input.is_action_just_pressed("ui_accept"):
		Global.fade_to_scene(Global.main_menu_path)
