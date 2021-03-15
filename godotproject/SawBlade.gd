extends KinematicBody2D

const FLOOR = Vector2(0, -1)
const MAX_SPEED = 20000
const MAX_HORIZONTAL_TRAVEL = 100
const NUM_RAMP_FRAMES = 50

var velocity = Vector2(0, 0)
var horizontal_direction = 1
var horizontal_directional_distance = 0
var speed_inc = MAX_SPEED / NUM_RAMP_FRAMES
var ideal_velocity = MAX_SPEED

var attackDamage = 1
var object_scale = 0
var radius = 0

var moveState = 0

enum MOVE_STATE {
	accelerating_e,
	full_speed_e
	decelerating_e,
}

func _ready():
#	radius = $SawBlade/PlayerCollision.shape.radius
#	var collNode = get_node("PlayerCollision/CollisionShape2D")
	radius = $PlayerCollision/CollisionShape2D.shape.radius
	moveState = MOVE_STATE.accelerating_e
	
func _process(delta):
	#calculate is the blade is slowing down, speeding up or at max_speed
	_calculate_ideal_velocity()
	
	# moving the blade
	velocity.x = ideal_velocity * delta * horizontal_direction
	velocity = move_and_slide(velocity, FLOOR)
	
	#rotating the sprite
	var rotation = velocity.x / radius
	rotation_degrees = int(rotation_degrees + rotation) % 360
	
	# if is_on_wall():
	# 	horizontal_direction *= -1
		
	print("IDEAL VELOCITY %f: " % ideal_velocity)
	print("VELOCITY %f: " % velocity.x)
	print("DIRECTION %d: " % horizontal_direction)
	print("MOVE_STATE %d: " % moveState)
		

func _calculate_ideal_velocity():
	if moveState == MOVE_STATE.decelerating_e:
		ideal_velocity = abs(ideal_velocity) - speed_inc
		if(ideal_velocity <= 0):
			horizontal_direction *= -1
			moveState = MOVE_STATE.accelerating_e
	elif moveState == MOVE_STATE.accelerating_e:
		ideal_velocity = abs(ideal_velocity) + speed_inc
		if(ideal_velocity >= MAX_SPEED):
			moveState = MOVE_STATE.full_speed_e
	elif moveState == MOVE_STATE.full_speed_e:
		ideal_velocity = MAX_SPEED

func _on_SawBladeArea_area_exited(area):
#	horizontal_direction *= -1
	moveState = MOVE_STATE.decelerating_e

func _on_PlayerCollision_body_entered(body):
	print(body)
	if (body.name == "Player"):
		body.takeDamage(attackDamage)

func take_damage(damage):
	pass
