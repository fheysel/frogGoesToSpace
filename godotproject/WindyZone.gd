extends Area2D


func _on_Node2D_body_entered(body):
	# Collect star piece is unique to Player
	if body.has_method("collect_star_piece"):
		$WindPlayer.play(0)
