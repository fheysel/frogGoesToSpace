extends Area2D



func _on_Star_body_entered(body: PhysicsBody2D)->void:
	queue_free()
