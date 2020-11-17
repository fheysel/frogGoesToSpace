extends KinematicBody2D

const GRAVITY = 10
const SPEED = 100
const FLOOR = Vector2(0, -1)
const FIREBALL = preload("res://AntAttackFire.tscn")

enum STATE{
	idle_e,
	detected_player_e,
	attacking_player_e
}

var velocity = Vector2(0, 0)
var direction = -1

var attackDamage = 1
var attackState = STATE.idle_e
var is_dead = false
	
func dead():
	is_dead = true
	velocity = 0
	$AnimatedSprite.play("dead")

func _physics_process(delta):
	if is_dead == false:
		if attackState == STATE.idle_e:
			#Play Animation, doesn't exist yet
			if direction == 1:
				$Orientation.scale.x = -1
			else:
				$Orientation.scale.x = 1
				
			$Orientation/Sprite.play("walk")
				
			#Movement for the ant
			velocity.x = SPEED * direction
			velocity.y += GRAVITY
			velocity = move_and_slide(velocity, FLOOR)
			
			if is_on_wall():
				direction *= -1

func begin_attack():
	var ClosestObject = $Orientation/RayCast2D.get_collider()
	#Check to see if the player is actually visible
	print(ClosestObject)
#	print(ClosestObject.name)
	if ClosestObject.name != "Tilemap":
		attackState = STATE.detected_player_e
		$ActionDelay.start()

func launch_attack():
	if attackState == STATE.detected_player_e:
		attackState = STATE.attacking_player_e
		
		var fireball = FIREBALL.instance()
		get_parent().add_child(fireball)
		fireball.position = $Orientation/Position2D.global_position
		fireball.set_direction(direction)
		
		$ActionDelay.start()

func _on_PlayerDetector_body_entered(body):
#	print(body.name)
	if body.name == "Player":		
		if attackState == STATE.idle_e:
			begin_attack()

func _on_ActionDelay_timeout():
	if attackState == STATE.detected_player_e:
		launch_attack()
	elif attackState == STATE.attacking_player_e:
		attackState = STATE.idle_e
		
		#Checks area for player after finishing attack [FGTS-78]
		var bodiesArr = $Orientation/Sprite/PlayerDetector.get_overlapping_bodies()
		for body in bodiesArr:
#			print(body.name)
			if body.name == "Player":
				begin_attack()
