extends KinematicBody2D

const FLOOR = Vector2(0, -1)
const SPEED = 9000
const SPEED_INC = 50

var velocity = Vector2(0, 0)
var direction = Vector2(1, 0)

var attackDamage = 1

enum STATE{
	idle_e,
	detected_player_e
	attacking_player_e
}

var attackState = STATE.idle_e

# Called when the node enters the scene tree for the first time.
func _ready():
	$Orientation/Area2D/CollisionShape2D.disabled = true
	direction.x = acos(rotation_degrees)
	direction.y = asin(rotation_degrees)
	print(direction)
	pass # Replace with function body.

func _physics_process(delta):
	#GetPlayerNode
	if (attackState == STATE.attacking_player_e):
		var level = get_parent().name;
		var playerPath = "/root/%s/Player" % level
		var playerNode = get_node(playerPath)
		
		#Compare Player position with rocket position
		direction = (playerNode.global_position - global_position).normalized();
		
		#Set the rocket to face the player
		var rocketRotation = direction.angle()
		$Orientation.rotation_degrees = rocketRotation * (180 / 3.14)
		
		#Move the rocket torwards the player
		velocity.x = SPEED * delta * direction.x
		velocity.y = SPEED * delta * direction.y
		velocity = move_and_slide(velocity, FLOOR)
	elif (attackState == STATE.idle_e):
		#Waiting to detect player

		var RC = $Orientation/RayCast2D.get_collider()
		if is_instance_valid(RC):
			if RC.name == "Player":

				attackState = STATE.detected_player_e
	elif (attackState == STATE.detected_player_e):
		
		$Orientation/Area2D/CollisionShape2D.disabled = false
		#ramp up to full speed before chasing after player
		if velocity.length() < SPEED * delta:
			velocity.x += (SPEED_INC * direction.x * delta)
			velocity.y += (SPEED_INC * direction.y * delta)
			print(velocity)
			velocity = move_and_slide(velocity, FLOOR)
		else:
			attackState = STATE.attacking_player_e
		

func _on_Area2D_body_entered(body):
	if(body.name) == "Player":
		body.takeDamage(attackDamage)
	queue_free()
