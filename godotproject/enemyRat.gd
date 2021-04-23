extends KinematicBody2D

# slash sound effect
# z index thing, idk what's going on

const GRAVITY = 10
const SPEED = 100
const FLOOR = Vector2(0, -1)

enum STATE{
	idle_e,
	detected_player_e,
	attacking_player_e
	hit_wall_e,
	taking_damage_e,
}

var health = 3
var is_dead = false

var velocity = Vector2(0, 0)
var direction = -1
var attackState = STATE.idle_e
var attackDamage = 1
var attackFrame = 0
var bounceCount = 0



var jumpForce = 205

func _physics_process(_delta):	
	if !is_dead:
		velocity.x = SPEED * direction
		velocity.y += GRAVITY

		if attackState == STATE.idle_e:
			# move forwards normally
			# check for the player
			
			if is_on_floor():
				var playerInRange = check_for_player()
				if playerInRange:
					attackState = STATE.detected_player_e
					$AudioRatSnarl.play()
					$ActionDelay.start()
			
		# PlayerDetected, freeze, gravity should still apply
		elif attackState & (STATE.detected_player_e | STATE.taking_damage_e):
			velocity.x = 0		
			
		elif attackState == STATE.attacking_player_e:
			# extra x velocity
			# check for attack collision
			# check for hitting the wall
			
			velocity.x += 300 * direction
			var bodiesArr = $Orientation/Sprite_SwipeAttack/SwipeAttack.get_overlapping_bodies()
			for body in bodiesArr:
				if Global.is_player(body):
					body.takeDamage(attackDamage)
			
			#Rat attack is over and the rat is back on the floor
			if is_on_floor() && attackFrame > 0:
				$Orientation/Sprite_SwipeAttack.visible = false
				$Orientation/Sprite_PNG.visible = true
				attackState = STATE.idle_e
				velocity.y = 0
				bounceCount = 0
			attackFrame += 1
		
		if is_on_wall():
			direction *= -1
			$Orientation.scale.x *= -1
			velocity.x *= -1
			if attackState == STATE.attacking_player_e:
				bounceCount += 1
		
		if bounceCount > 0:
			velocity.x = velocity.x / (2 * bounceCount)

		velocity = move_and_slide(velocity, FLOOR)

func check_for_player():
	var RayCastList = [
		$Orientation/RayCastFront_Top.get_collider(),
		$Orientation/RayCastFront_Middle.get_collider(),
		$Orientation/RayCastFront_Bottom.get_collider(),
		]
	
	for bodyHit in RayCastList:
		if is_instance_valid(bodyHit):
			if Global.is_player(bodyHit):
				return true
	return false

func launch_Attack():
	$Orientation/Sprite_SwipeAttack.visible = true
	$Orientation/Sprite_PNG.visible = false
	$AudioRatSwipe.play()
	velocity.y -= jumpForce
	attackFrame = 0

func take_damage(attack_damage):
	if !is_dead and $InvulnerableTimer.is_stopped():
		health = health - attack_damage
		if health <= 0:
			dead()
		else:
			# Set the enemy in the invulnerable state
			attackState = STATE.taking_damage_e
			$Orientation/Sprite_SwipeAttack.visible = false
			$Orientation/Sprite_PNG.visible = true
			$InvulnerableTimer.start()
			# Handle enemy flashing after taking damage
			$InvulnerableFlashTimer.start()
			$Orientation/Sprite_PNG.modulate.a = 0.3
			# Set sprite animation
	#		$Orientation/Sprite_PNG.play("hurt")
			# Handle enemy health

func dead():
	is_dead = true
	velocity = 0
	queue_free()
	
	
func _on_InvulnerableTimer_timeout():
	# Set player to visible
	$Orientation/Sprite_PNG.modulate.a = 1
	# Re-enable their logic
	attackState = STATE.idle_e
	# Trigger the raycast so they will shoot at the player
#	trigger_raycast()

func _on_InvulnerableFlashTimer_timeout():
	if $InvulnerableTimer.is_stopped():
		# Player isn't vulnerable anymore! Stop this timer until next hit
		$InvulnerableFlashTimer.stop()
	else:
		# Flash between transparencies
		$Orientation/Sprite_PNG.modulate.a = 1 - $Orientation/Sprite_PNG.modulate.a


func _on_PlayerDetection_body_entered(body):
	pass

func _on_ActionDelay_timeout():
	if attackState == STATE.detected_player_e:
		attackState = STATE.attacking_player_e
		launch_Attack()
	elif attackDamage == STATE.hit_wall_e:
		attackState = STATE.idle_e
