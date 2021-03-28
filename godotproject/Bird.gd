extends KinematicBody2D

const FLOOR = Vector2(0, -1)
const SPEED = 6000
const DIVE_SPEED = 9500
const VERTICAL_TRAVEL = 8000

enum STATE{
	idle_e,
	detected_player_e,
	attacking_player_e
}

var attackState = STATE.idle_e
var velocity = Vector2(0, 0)

var horizontal_direction = 1
var horizontal_directional_distance = 0
var max_horizontal_directional_distance = 20000

var vertical_direction = 1
var vertical_directional_distance = 0
var max_vertical_directional_distance = VERTICAL_TRAVEL

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if attackState == STATE.idle_e:
		velocity.x = SPEED * delta * horizontal_direction

		velocity = move_and_slide(velocity, FLOOR)
		horizontal_directional_distance += SPEED * delta
		
		if horizontal_directional_distance > max_horizontal_directional_distance:
			horizontal_direction *= -1
			$Orientation.scale.x *= -1
			horizontal_directional_distance = 0
			
		#Use RayCast to check for player
		var RC = $Orientation/RayCast2D.get_collider()
		if is_instance_valid(RC):
			if RC.name == "Player":
				attackState = STATE.detected_player_e
				
				$ActionDelay.start()
	
	elif attackState == STATE.attacking_player_e:		
		
		velocity.y = 0.001 * (DIVE_SPEED - vertical_directional_distance) * (DIVE_SPEED - vertical_directional_distance) * delta * vertical_direction
		velocity.x = (DIVE_SPEED + SPEED) * delta * horizontal_direction
		
		velocity = move_and_slide(velocity, FLOOR)
		vertical_directional_distance += velocity.y
		
		if (vertical_directional_distance > max_vertical_directional_distance && vertical_direction == 1) || vertical_directional_distance < max_vertical_directional_distance && vertical_direction == -1:

			vertical_direction *= -1
			max_vertical_directional_distance = 0
			
			#Player has completed the swoop attack (gone down and up)
			if vertical_direction == 1:
				attackState = STATE.idle_e
				max_vertical_directional_distance = VERTICAL_TRAVEL
				velocity.y = 0

func take_damage(damage):
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
		health = health - damage
		attackState = STATE.idle_e
		if health <= 0:
			dead()
	
func dead():
	is_dead = true
	velocity = 0
	queue_free()

func _on_ActionDelay_timeout():
	if attackState == STATE.detected_player_e:

		attackState = STATE.attacking_player_e

func _on_PlayerHitBoxArea_body_entered(body):
	if body.name == "Player":
		body.takeDamage(1)

