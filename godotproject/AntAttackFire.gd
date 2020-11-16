extends Node2D

var speed = 5
var velocity = Vector2()
var distance_traveled = 0
var direction = 1

func _physics_process(delta):
	velocity.x = speed * direction
	velocity.y = 0 # not needed, it's already 0
	translate(velocity)
	distance_traveled += speed
	
	if distance_traveled > 200:
		queue_free()

func _on_PlayerCollisionArea_body_entered(body):
	if "Player" in body.name:
		body.takeDamage(3)

func set_direction(dir):
	if dir != direction:
		$Sprite.flip_h = true
	direction = dir

