extends KinematicBody2D

const GRAVITY = 10
const SPEED = 100
const FLOOR = Vector2(0, -1)
const FIREBALL = preload("res://AntAttackFire.tscn")

enum STATE{
	idle_e,
	detected_player_e,
	attacking_player_e,
	taking_damage_e
}

var velocity = Vector2(0, 0)
var direction = -1

var attackDamage = 1
var attackState = STATE.idle_e
var is_dead = false

var tongue_can_damage = true
var health = 3
	
func _ready():
	# If set to hard diffictult enable collisions from hitting enemies	
	if($"/root/Global".difficulty == $"/root/Global".DIFFICULTY.HARD_MODE_e):
		$Orientation/PlayerCollision.set_collision_mask_bit(1,1)
	
func dead():
	is_dead = true
	velocity = 0
	queue_free()

func trigger_raycast():
	# .1 second delay to gived RayCasts time to switch directions
	$ActionDelay.start(.1)
	# Set the wait time to a normal amount again
	$ActionDelay.wait_time = 0.5

func _physics_process(_delta):
	if is_dead == false:
		if attackState == STATE.idle_e:
			$Orientation/Sprite.play("walk")
				
			#Movement for the ant
			velocity.x = SPEED * direction
			velocity.y += GRAVITY
			velocity = move_and_slide(velocity, FLOOR)
			
			if is_on_wall():
				# Change direction
				direction *= -1
				$Orientation.scale.x *= -1
			
				# Send out the raycast again after changing direction
				trigger_raycast()

func take_damage(attack_damage):
	if !is_dead and $InvulnerableTimer.is_stopped():
		# Set the enemy in the invulnerable state
		$InvulnerableTimer.start()
		attackState = STATE.taking_damage_e
		# Handle enemy flashing after taking damage
		$InvulnerableFlashTimer.start()
		$Orientation/Sprite.modulate.a = 0.3
		# Set sprite animation
		$Orientation/Sprite.play("hurt")
		# Handle enemy health
		health = health - attack_damage
		if health <= 0:
			dead()

func begin_attack():
	var RayCastList = [$Orientation/RayCast_Top.get_collider(), $Orientation/RayCast_Middle.get_collider(), $Orientation/RayCast_Bottom.get_collider()]
	
	$Orientation/Sprite.play("fireball")
	
	for RC in RayCastList:
		if is_instance_valid(RC):
			if RC.name == "Player":
				attackState = STATE.detected_player_e
				$ActionDelay.start()
				$AttackSoundPlayer.play(0)
	

func launch_attack():
	if attackState == STATE.detected_player_e:
		attackState = STATE.attacking_player_e
		
		var fireball = FIREBALL.instance()
		get_parent().add_child(fireball)
		fireball.position = $Orientation/Position2D.global_position
		fireball.set_direction(direction)
		
		$ActionDelay.start()

func _on_PlayerDetector_body_entered(body):	
	if body.name == "Player":		
		if attackState == STATE.idle_e:
			begin_attack()

func _on_ActionDelay_timeout():
	if attackState == STATE.detected_player_e:
		launch_attack()
	elif attackState == STATE.attacking_player_e || attackState == STATE.idle_e:
		attackState = STATE.idle_e
		
		#Checks area for player after finishing attack [FGTS-78]
		var bodiesArr = $Orientation/Sprite/PlayerDetector.get_overlapping_bodies()
		for body in bodiesArr:
			if body.name == "Player":
				begin_attack()

func _on_InvulnerableTimer_timeout():
	# Set player to visible
	$Orientation/Sprite.modulate.a = 1
	# Re-enable their logic
	attackState = STATE.idle_e
	# Trigger the raycast so they will shoot at the player
	trigger_raycast()


func _on_InvulnerableFlashTimer_timeout():
	if $InvulnerableTimer.is_stopped():
		# Player isn't vulnerable anymore! Stop this timer until next hit
		$InvulnerableFlashTimer.stop()
	else:
		# Flash between transparencies
		$Orientation/Sprite.modulate.a = 1 - $Orientation/Sprite.modulate.a


func _on_Area2D_body_entered(body):
	if(body.name == "Player"):
		body.takeDamage(attackDamage)
