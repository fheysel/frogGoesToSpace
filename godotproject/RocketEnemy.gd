extends KinematicBody2D

const FLOOR = Vector2(0, -1)
const SPEED = 22500
const SPEED_INC = SPEED / 30

var velocity = Vector2(0, 0)

var direction = Vector2(1, 0)
var pastDirection = Vector2(0, 1)

var attackDamage = 1
var alpha = 0.08

enum STATE{
	detected_player_e
	attacking_player_e
}

var attackState = STATE.detected_player_e

# Called when the node enters the scene tree for the first time.
func _ready():
	$Orientation/Area2D/CollisionShape2D.disabled = true
	direction.x = 0
	direction.y = -1
	attackState = STATE.detected_player_e
	$RocketLaunchSFX.play()

func _physics_process(delta):
	if (attackState == STATE.attacking_player_e):
		var playerNode = get_node("../../Player")
		
		#Compare Player position with rocket position
		direction = (playerNode.global_position - global_position).normalized();
		
		#Filter Player PositionData
		direction.x = pastDirection.x + (direction.x - pastDirection.x) * alpha;
		direction.y = pastDirection.y + (direction.y - pastDirection.y) * alpha;
		direction = direction.normalized();
		pastDirection = direction;
		
		#Move the rocket torwards the player
		velocity.x = SPEED * delta * direction.x
		velocity.y = SPEED * delta * direction.y
		
		#Set the rocket to face the player
		var rocketRotation = direction.angle()
		$Orientation.rotation_degrees = (rocketRotation * (180 / 3.14)) + 90
		velocity = move_and_slide(velocity, FLOOR)
	elif (attackState == STATE.detected_player_e):
		#ramp up to full speed before chasing after player
		if velocity.length() < SPEED * delta:
			velocity.x += (SPEED_INC * direction.x * delta)
			velocity.y += (SPEED_INC * direction.y * delta)
			velocity = move_and_slide(velocity, FLOOR)
		else:			
			pastDirection = direction;
			attackState = STATE.attacking_player_e
			$Orientation/Area2D/CollisionShape2D.disabled = false
		
func _on_Area2D_body_entered(body):
	if Global.is_player(body):
		body.takeDamage(attackDamage)

	explode()
	
func _on_Timer_timeout():
	get_parent()._on_rocket_explode()
	queue_free()



func _on_Area2D_area_entered(area):
	# if the laser is in attack state, make rocket explode
	if ("LaserWall" in area.name && area.AnimationState == 1): 
		explode()

		
func explode():
	$Timer.start()
	$Orientation/AnimatedSprite.set_visible(false)
	set_physics_process(false)
	velocity = Vector2(0,0)
	$Orientation/BoomSprite.play("default")
	$RocketExplodeSFX.play()
	
