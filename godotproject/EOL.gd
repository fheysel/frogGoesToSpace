extends Area2D

func _on_EOL_body_entered(body):
	if "is_god" in body:
		print("sda")
		get_tree().change_scene("res://Level" + str(int(get_tree().current_scene.name) + 1) + ".tscn")
		
