extends HSlider

var inhibit_next_sfx = false

func set_volume(volume):
	inhibit_next_sfx = true
	value = volume
	Global.sfx_volume = value

func _ready():
	Global.sfx_volume = value

func _on_SfxVolumeSlider_value_changed(value):
	Global.sfx_volume = value
	if !inhibit_next_sfx:
		$AudioStreamPlayer.play()
	inhibit_next_sfx = false
