extends Area2D

func _on_DeathPlane_body_entered(body):
	if  body.name == "Player":
		body.takeDamage(1);
		Global.fade_to_scene("res://Level" + str(int(get_tree().current_scene.name)) + ".tscn")
