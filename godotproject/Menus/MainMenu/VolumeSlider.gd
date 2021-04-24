extends HSlider

func get_global_volume():
	value = Global.title_volume

func _process(_delta):
	if Input.is_action_just_pressed("ui_left"):
		value -= 0.1
	if Input.is_action_just_pressed("ui_right"):
		value += 0.1

func _on_VolumeSlider_value_changed(value):
	Global.title_volume = value
