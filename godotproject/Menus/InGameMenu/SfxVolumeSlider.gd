extends HSlider

var inhibit_next_sfx = false

func get_global_volume():
	inhibit_next_sfx = true
	value = Global.sfx_volume

func _on_SfxVolumeSlider_value_changed(value):
	Global.sfx_volume = value
	if !inhibit_next_sfx:
		$AudioStreamPlayer.play()
	inhibit_next_sfx = false
