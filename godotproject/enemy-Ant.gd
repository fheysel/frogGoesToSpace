extends KinematicBody2D

const GRAVITY = 10
const SPEED = 100
const FLOOR = Vector2(0, -1)

var velocity = Vector2(0, 0)
var direction = 1

var attackDamage = 1
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
		#Play Animation
		if direction == 1:
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.flip_h = false
			
		$AnimatedSprite.play("walk")
			
		#Movement for the ant
		velocity.x = SPEED * direction
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)
			
		#flip direction when hittin wall
		if is_on_wall():
			direction *= -1
		
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PlayerDetector_body_entered(body):
	print("Enemy has hit player")
	if(body.isVulnerable):
		print("Calling player takeDamage(damage)")
		body.takeDamage(attackDamage)

