extends Area2D

func _on_EOL_body_entered(body):
	# Change the current scene to the next level
	if  body.name == "Player": 
		get_tree().change_scene("res://Level" + str(int(get_tree().current_scene.name) + 1) + ".tscn")
