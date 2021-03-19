extends Area2D

var COLLECT_ID = 0

func _on_Star_body_entered(body: PhysicsBody2D)->void:
	if body.has_method("collect"):
		body.collect(self)
