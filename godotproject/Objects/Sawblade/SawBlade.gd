extends KinematicBody2D

const FLOOR = Vector2(0, -1)
const MAX_SPEED = 20000
const MIN_SPEED = 1000
const MAX_HORIZONTAL_TRAVEL = 100
const NUM_RAMP_FRAMES = 45
const D_RAMP = 125

var velocity = Vector2(0, 0)
var direction = 1
var horizontal_directional_distance = 0
var speed_inc = MAX_SPEED / NUM_RAMP_FRAMES
var ideal_velocity = MAX_SPEED

var attackDamage = 1
var object_scale = 0
var radius = 0
var totalLength = 0
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
	position = $StartPos.position;	
	ideal_velocity = 10
	totalLength = ($EndPos.position - $StartPos.position).length()
	print("accelerating")

func _process(delta):
	#Accelerate the full velocity when leaving one point initally
	_calculate_ideal_velocity()
	
	#Now we do the actual velocity
	#This is temporary purely for testing speedup logic
#	velocity.x = ideal_velocity * delta * horizontal_direction
#	velocity = move_and_slide(velocity, FLOOR)

	#Actual logic:
	var dir_unit_vector = ($EndPos.position - $StartPos.position).normalized()
	velocity = dir_unit_vector * ideal_velocity * delta * direction
	velocity = move_and_slide(velocity, FLOOR)
	#	find unit vector between the Start and End Position
	#	(End - Start).normalize()
	#	velocity.x = unitVector * ideal_velocity * delta * direction
	
	#rotating the sprite
	var rotation = velocity.length() / radius * direction
	rotation_degrees = int(rotation_degrees + rotation) % 360

func _calculate_ideal_velocity():
	#Setting originating and ending positions
	var original_position = $StartPos.position;
	var target_position = $EndPos.position;
	if (direction == -1):
		original_position = $EndPos.position
		target_position = $StartPos.position
		
	var dStart = (position - original_position).length()
	var dEnd = (position - target_position).length()
	
	# if acclerating and less than a quarter away from the StartPos keep accelerating
	if (moveState == MOVE_STATE.accelerating_e):
		ideal_velocity += speed_inc
		ideal_velocity = min(ideal_velocity, MAX_SPEED)
#		# once we are a quarter through we stop accelerating the saw
		if (dStart  > (D_RAMP)):		
			moveState = MOVE_STATE.full_speed_e
	
	elif (moveState == MOVE_STATE.full_speed_e):
#		#once we are 3/4 way through we start decelerating
		if (dEnd < D_RAMP):
			moveState = MOVE_STATE.decelerating_e
	
	elif (moveState == MOVE_STATE.decelerating_e):
		ideal_velocity -= speed_inc
		ideal_velocity = max(ideal_velocity, MIN_SPEED)
		# check to see if we have passed the target point
		if(dStart > totalLength):
			direction *= -1
			moveState = MOVE_STATE.accelerating_e		

func _on_SawBladeArea_area_exited(area):
	pass
	#	horizontal_direction *= -1
	#	moveState = MOVE_STATE.decelerating_e

func _on_PlayerCollision_body_entered(body):
	print(body)
	if (body.name == "Player"):
		body.takeDamage(attackDamage)

func take_damage(damage):
	pass
