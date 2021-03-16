extends Area2D

enum ANIMATIONS {
	IDLE, 
	ATTACKING,
	MAX_ANIMATIONS,
}

var AnimationStates = ["Idle", "Attacking"]
var AnimationState = ANIMATIONS.IDLE
var inside = false
var player
var attackDamage = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play(AnimationStates[ANIMATIONS.IDLE])
	
func _process(_delta):
	if inside == true and AnimationState == ANIMATIONS.ATTACKING:
		player.takeDamage(attackDamage)
		
# If we're in an attack state do damage
func _on_Area2D_body_entered(body):
	if Global.is_player(body):
		inside = true
		player = body
		
func _on_Area2D_body_exited(body):
	if Global.is_player(body):
		inside = false

#flips between 1 of 2 animations States
func _on_Timer_timeout():
	AnimationState = (AnimationState + 1) % ANIMATIONS.MAX_ANIMATIONS
	$AnimatedSprite.play(AnimationStates[AnimationState])
	
	if AnimationState == ANIMATIONS.ATTACKING:
		$LaserAttackAudio.play()
	elif AnimationState == ANIMATIONS.IDLE:
		$LaserIdleAudio.play()
		
	$Timer.start()




