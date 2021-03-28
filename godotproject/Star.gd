extends Area2D

func _on_Star_body_entered(body: PhysicsBody2D)->void:
	if body.has_method("collect_star_piece"):
		body.collect_star_piece(self)
