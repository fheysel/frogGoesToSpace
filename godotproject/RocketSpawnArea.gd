extends Area2D

const ROCKET = preload("res://RocketEnemy.tscn")

var rocketMutex = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area2D_body_entered(body):
	if(body.name == "Player" && rocketMutex <= 0):
		print("Player detected, starting timer")
		$Timer.start()

func _on_Timer_timeout():
	if (rocketMutex <= 0):
		rocketMutex += 1
		print("1 rockets in the scene")
		print("Timer done, launching rocket")
		var rocket = ROCKET.instance()
		add_child(rocket)
		rocket.set_position($Position2D.get_position())
		print("starting position")
		print(rocket.get_global_position())
	
func _on_rocket_explode():
	print("Rocket is being deleted")
	if (rocketMutex > 0):
		rocketMutex -= 1
	
	# Check to see if the player is still in the area
	var bodiesArr = get_overlapping_bodies()
	for body in bodiesArr:
		if body.name == "Player":
			print("Player detected, starting timer")
			$Timer.start()
