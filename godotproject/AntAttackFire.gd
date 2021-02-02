extends KinematicBody2D

const FLOOR = Vector2(0, -1)
const SPEED = 250

var velocity = Vector2(0, 0)
var distance_traveled = 0
var direction = 1
var attackDamage = 1

func _physics_process(delta):

	velocity.x = SPEED * direction
	velocity.y = 0 # not needed, it's already 0
	velocity = move_and_slide(velocity, FLOOR)
	distance_traveled += SPEED * delta
	
	if distance_traveled > 200 || is_on_wall():
		dead()

func _on_PlayerCollisionArea_body_entered(body):
	if "Player" in body.name:
		body.takeDamage(attackDamage)
		dead()

func dead():
	$FireballExplodeSoundPlayer.play(0)
	queue_free()

func set_direction(dir):
	if dir != direction:
		$Sprite.flip_h = true
	direction = dir
