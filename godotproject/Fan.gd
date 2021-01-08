extends Area2D

	
func _on_PlayerDetector_body_entered(body):	
	print('in fan')
	
	var RayCastList = [$Orientation/RayCastLeft.get_collider(), 
					   $Orientation/RayCastMiddle.get_collider(), 
					   $Orientation/RayCastRight.get_collider()]
					
	for RC in RayCastList:
		if is_instance_valid(RC):
			if body.has_method('do_movement'):	
				body.do_movement(Vector2(0, -2400))
	
	


func _on_Fan_body_entered(body):
	print('boogity boo')
	body.wind_speed = Vector2(-2, -2)
	# body.do_movement(-1)


func _on_Fan_body_exited(body):
	print('bipiity bop')
	body.wind_speed = Vector2(1, 1)
	
