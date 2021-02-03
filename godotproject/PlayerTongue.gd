extends Node2D

signal tongue_swing

# We removed the 0.6 scale on the frog,
# so we divide by 0.6 here to compensate.
export (float) var shoot_speed = 1500 * 0.6
export (float) var max_shoot_dist = 400 * 0.6

const COLLISION_LAYER_TONGUEABLE         = 0x3
const COLLISION_LAYER_TONGUE_CAN_DAMAGE  = 0x6
const COLLISION_LAYER_TONGUE_CAN_COLLECT = 0x7

var idle = true
var shooting = false
var swinging = false

var shoot_direction = Vector2.RIGHT
var tongue_length = 0

var tongue_damage = 1

func get_tongue_vector():
	return shoot_direction * tongue_length

func get_global_target_position():
	return get_global_transform().xform(get_tongue_vector())

func update_tongue_location():
	var loc = get_tongue_vector()
	$TongueRaycast.cast_to = loc
	$Sprite.position = loc

# Called when the node enters the scene tree for the first time.
func _ready():
	start_idle()

func start_idle():
	idle = true
	shooting = false
	swinging = false

	$Sprite.visible = false
	# Stop all sound effects
	$ShootSoundPlayer.playing = false
	$StickSoundPlayer.playing = false

func handle_idle(_delta):
	pass

func start_shoot(dirn):
	idle = false
	shooting = true
	swinging = false

	shoot_direction = dirn
	tongue_length = 0
	update_tongue_location()

	# Disable the raycast for the first frame that we're shooting,
	# to prevent collision with the previous tongue position
	$TongueRaycast.enabled = false

	$Sprite.visible = true
	$ShootSoundPlayer.play(0)

func handle_shoot(delta):

	# Check if the raycast is enabled and hit something
	if $TongueRaycast.enabled and $TongueRaycast.is_colliding():
		var colliding = $TongueRaycast.get_collider()

		if colliding.get_collision_layer_bit(COLLISION_LAYER_TONGUE_CAN_DAMAGE):
			colliding.take_damage(tongue_damage)
			start_idle()
			
		elif colliding.get_collision_layer_bit(COLLISION_LAYER_TONGUE_CAN_COLLECT):
			get_parent().collect_star_piece(colliding)


		elif colliding.get_collision_layer_bit(COLLISION_LAYER_TONGUEABLE):
			start_swing($TongueRaycast.get_collider(), $TongueRaycast.get_collision_point())

	# If the raycast isn't enabled, enable it for next frame.
	if !$TongueRaycast.enabled:
		$TongueRaycast.enabled = true

	if tongue_length >= max_shoot_dist:
		# We didn't hit anything. Stop shooting.
		start_idle()

	tongue_length += shoot_speed * delta
	update_tongue_location()

func start_swing(_body, global_point):
	idle = false
	shooting = false
	swinging = true

	$TongueRaycast.enabled = false
	emit_signal("tongue_swing", global_point)

	$Sprite.visible = false
	# Stop playing shoot sound effect once tongue sticks
	$ShootSoundPlayer.playing = false
	$StickSoundPlayer.play(0)

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

func _on_Player_tongue_stop():
	if swinging:
		start_idle()
