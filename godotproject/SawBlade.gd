extends KinematicBody2D

const FLOOR = Vector2(0, -1)
const MAX_SPEED = 20000
const NUM_RAMP_FRAMES = 50
const SPEED_INC = MAX_SPEED / NUM_RAMP_FRAMES

var velocity = Vector2(0, 0)
var horizontal_direction = 1
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
	radius = $PlayerCollision/CollisionShape2D.shape.radius
	moveState = MOVE_STATE.accelerating_e

func _physics_process(delta):
	#calculate is the blade is slowing down, speeding up or at max_speed
	_calculate_ideal_velocity()
	
	# moving the blade
	velocity.x = ideal_velocity * delta * horizontal_direction
	velocity = move_and_slide(velocity, FLOOR)
	
	#rotating the sprite
	var rotation = velocity.x / radius
	rotation_degrees = int(rotation_degrees + rotation) % 360
	

func _calculate_ideal_velocity():
	if moveState == MOVE_STATE.decelerating_e:
		ideal_velocity = abs(ideal_velocity) - SPEED_INC
		if(ideal_velocity <= 0):
			horizontal_direction *= -1
			moveState = MOVE_STATE.accelerating_e
	elif moveState == MOVE_STATE.accelerating_e:
		ideal_velocity = abs(ideal_velocity) + SPEED_INC
		if(ideal_velocity >= MAX_SPEED):
			moveState = MOVE_STATE.full_speed_e
	elif moveState == MOVE_STATE.full_speed_e:
		ideal_velocity = MAX_SPEED

func _on_SawBladeArea_area_exited(area):
	# Check that our collision box is the area that exited the SawBladeArea
	if area == $PlayerCollision:
		moveState = MOVE_STATE.decelerating_e

func _on_PlayerCollision_body_entered(body):
	if Global.is_player(body):
		body.takeDamage(attackDamage)

# In order to stop the tongue when it hits the sawblade, we have our "tongue_can_damage" collision bit set.
# However, we need to have the `take_damage` function, so we just have an empty one here.
func take_damage(_damage):
	pass
