extends Area2D

const ROCKET = preload("res://RocketEnemy.tscn")
var rocketMutex = 0

func _on_Area2D_body_entered(body):
	if(body.name == "Player" && rocketMutex <= 0):
		$Timer.start()

func _on_Timer_timeout():
	if (rocketMutex <= 0):
		rocketMutex += 1
		var rocket = ROCKET.instance()
		add_child(rocket)
		rocket.set_position($Position2D.get_position())

func _on_rocket_explode():
	if (rocketMutex > 0):
		rocketMutex -= 1
	
	# Check to see if the player is still in the area
	var bodiesArr = get_overlapping_bodies()
	for body in bodiesArr:
		if body.name == "Player":
			$Timer.start()
