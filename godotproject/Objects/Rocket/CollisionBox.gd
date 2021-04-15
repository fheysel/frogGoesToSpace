extends Area2D


func _on_Spike_body_entered(body):
		
	if body.has_method("takeDamage"):
		body.takeDamage(1)

func _on_CollisionBox_body_entered(body):
	if get_parent().is_playing() == true: # only do damage if the particle affects are on ie jet is on
		if body.has_method("takeDamage"):
			body.takeDamage(1)


func _on_Jet1_animation_finished():
	if get_parent().animation != 'looping_stream':
		get_parent().play('looping_stream')
