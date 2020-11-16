extends KinematicBody2D

signal fireball_start

const GRAVITY = 10
const SPEED = 100
const FLOOR = Vector2(0, -1)
const FIREBALL = preload("res://AntAttackFire.tscn")

enum STATE{
	idle,
	detected_player,
	attacking_player
}

var velocity = Vector2(0, 0)
var direction = -1

var attackDamage = 1
var attackState = STATE.idle
var is_dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func dead():
	is_dead = true
	velocity = 0
	$AnimatedSprite.play("dead")

func _physics_process(delta):
	
	if is_dead == false:
		if attackState == STATE.idle:
			#Play Animation
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func launch_attack():
	if attackState == STATE.detected_player:
		attackState = STATE.attacking_player
		var fireball = FIREBALL.instance()
		get_parent().add_child(fireball)
		fireball.position = $Orientation/Position2D.global_position
		fireball.direction = direction
		$ActionDelay.start()

func _on_PlayerDetector_body_entered(body):
	if attackState == STATE.idle:
		attackState = STATE.detected_player
		$ActionDelay.start()

func _on_ActionDelay_timeout():
	if attackState == STATE.detected_player:
		launch_attack()
	elif attackState == STATE.attacking_player:
		attackState = STATE.idle
