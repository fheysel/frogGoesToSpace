extends HSlider

func _ready():
	Global.sfx_volume = value

func _on_SfxVolumeSlider_value_changed(value):
	Global.sfx_volume = value
	$AudioStreamPlayer.play()
