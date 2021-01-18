extends Area2D


func _on_Fan_body_entered(body):
	if body.has_method("do_movement"):
		body.wind_speed = Vector2(-2, -2)


func _on_Fan_body_exited(body):
	if body.has_method("do_movement"):
		body.wind_speed = Vector2(1, 1)
	
