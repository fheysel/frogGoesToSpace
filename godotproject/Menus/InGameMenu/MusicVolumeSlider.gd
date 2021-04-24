extends HSlider

func get_global_volume():
	value = Global.music_volume

func _on_MusicVolumeSlider_value_changed(value):
	Global.music_volume = value

func _on_MusicVolumeSlider_focus_entered():
	$AudioStreamPlayer.play()

func _on_MusicVolumeSlider_focus_exited():
	$AudioStreamPlayer.stop()
