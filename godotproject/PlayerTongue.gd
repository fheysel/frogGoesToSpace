extends Node2D

signal tongue_swing

# We removed the 0.6 scale on the frog,
# so we divide by 0.6 here to compensate.
export (float) var shoot_speed = 1500 * 0.6
export (float) var max_shoot_dist = 400 * 0.6

var shoot_direction = Vector2.RIGHT
var idle = true
var shooting = false
var swinging = false


# Called when the node enters the scene tree for the first time.
func _ready():
	start_idle()
	
func start_idle():
	idle = true
	shooting = false
	swinging = false
	
	$Sprite.visible = false
	$TongueCollisionArea/CollisionShape2D.disabled = true
	# Stop all sound effects
	$ShootSoundPlayer.playing = false
	$StickSoundPlayer.playing = false
	position = Vector2.ZERO

func handle_idle(_delta):
	pass

func start_shoot(dirn):
	idle = false
	shooting = true
	swinging = false
	$Sprite.visible = false
	$TongueCollisionArea/CollisionShape2D.disabled = false
	shoot_direction = dirn
	$ShootSoundPlayer.play(0)
	
func handle_shoot(delta):
	# Advance tongue in direction 
	position += shoot_direction * shoot_speed * delta 

	if position.length_squared() >= max_shoot_dist * max_shoot_dist:
		# We didn't hit anything. Stop shooting.1)
		start_idle()

func start_swing(_body):
	idle = false
	shooting = false
	swinging = true
	$Sprite.visible = false
	# We need to use set_deferred to set this property in order to avoid an
	# error. I believe it is because we are adjusting this from the
	# TongueCollisionArea's event, and it doesn't like us adjusting properties
	# while handling its events. [FGTS-75]
	$TongueCollisionArea/CollisionShape2D.set_deferred('disabled', true)
	# Stop playing shoot sound effect once tongue sticks
	$ShootSoundPlayer.playing = false
	$StickSoundPlayer.play(0)
	emit_signal("tongue_swing", get_global_transform().xform(Vector2.ZERO))

func handle_swing(_delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if idle:
		handle_idle(delta)
	elif shooting:
		handle_shoot(delta)
	elif swinging:
		handle_swing(delta)
	else:
		print_debug('Invalid tongue state. Resetting...')
		idle = true

func _on_Player_tongue_start(facing):
	if idle:
		start_shoot(facing)

func _on_TongueCollisionArea_body_entered(body):
	if shooting:
		start_swing(body)

func _on_Player_tongue_stop():
	if swinging:
		start_idle()
