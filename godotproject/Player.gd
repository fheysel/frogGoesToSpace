extends KinematicBody2D

signal tongue_start
signal tongue_stop

export (int) var speed = 200
export (int) var jump_speed = -500
export (int) var gravity = 1200
export (float) var jump_length = 10 / 60.0
export (float) var shorthop_length = 6 / 60.0
export (float) var shorthop_ratio = 0.6
export (float) var swing_user_anglespeed_per_s = 1
export (float) var swing_user_radius_per_s = 40
# How long to delay between hop sound effects
export (float) var hop_sound_timer_period = 0.2
# Used to add some randomness to hop sounds - see its use
# in the code below for more detail
export (float) var hop_sound_timer_period_variance = 0.1


var velocity = Vector2.ZERO
var jump_frame_countdown = 0
var jump_shorthop_countdown = 0
var facing = Vector2.RIGHT

var user_direction = Vector2.ZERO
var jump_pressed = false
var tongue_pressed = false
var jump_held = false
var tongue_held = false

var swing_angular_speed = 0
var swing_radius = 0
var swing_angle = 0
var swing_pivot_position = Vector2.ZERO

# Timer used to add delay between hop sound effects
# This is temporary - in the future, hop sound will be synchronized
# with the hop animation
var hop_sound_timer = 0

# This counter keeps track of the number of star pieces collected.
# This may be temporary, depending on if we want to track the number of star pieces
# collected in-between levels or in-between deaths.
var star_piece_count = 0

func is_zero(x):
	return abs(x) < 0.01

func start_swing():
	# Calculate initial angle and radius
	var swing_vec = update_swing_radius_angle()
	var swing_dir_vec = swing_vec.rotated(PI/2)
	var dotprod = swing_dir_vec.dot(velocity)
	if abs(dotprod)<  0.01 or swing_radius < 0.01:
		swing_angular_speed = 0
	else:
		swing_angular_speed = dotprod / abs(dotprod) * pow(abs(dotprod), 0.5) / max(1, swing_radius)

func stop_swing():
	# Convert swinging angular momentum into player velocity
	velocity = Vector2.DOWN.rotated(swing_angle) * swing_angular_speed * swing_radius
	print_debug('Stop swing: Velocity=',velocity)
	emit_signal("tongue_stop")

func update_swing_radius_angle():
	# Calculate current angle and radius
	var frog_pos = get_global_transform().xform(Vector2.ZERO)
	var swing_vec = frog_pos - swing_pivot_position
	swing_radius = swing_vec.length()
	swing_angle = swing_vec.angle() # Angle from positive X-axis to swing vector
	return swing_vec


func get_input():
	var l = Input.is_action_pressed("walk_left")
	var r = Input.is_action_pressed("walk_right")
	var u = Input.is_action_pressed("look_up")
	var d = Input.is_action_pressed("look_down")
	user_direction.x = 0
	if l:
		user_direction.x -= 1
	if r:
		user_direction.x += 1
	user_direction.y = 0
	if u:
		user_direction.y -= 1
	if d:
		user_direction.y += 1
	jump_pressed = Input.is_action_just_pressed("jump")
	jump_held = Input.is_action_pressed("jump")
	tongue_pressed = Input.is_action_just_pressed("tongue")
	tongue_held = Input.is_action_pressed("tongue")

func _draw():
	# THIS IS JUST DEBUG
	# TODO: Remove
	# Draw swinging velocity vector
	if $PlayerTongue.swinging:
		var tgt = Vector2.DOWN.rotated(swing_angle) * swing_angular_speed * 100
		draw_line(Vector2(0,0), tgt, Color(1,0,0))

func do_movement(delta):
	if $PlayerTongue.swinging:
		# Handle user input
		swing_angular_speed += swing_user_anglespeed_per_s * -user_direction.x * delta
		# TODO: Fix this and uncomment
		# # We don't directly compute the position. We need to use move_and_collide
		# var change_in_swing_radius = swing_user_radius_per_s * user_direction.y * delta
		# if abs(change_in_swing_radius) > 0.01:
		# 	var proposed_movement = Vector2.RIGHT.rotated(swing_angle) * change_in_swing_radius
		# 	collision_info = move_and_collide(proposed_movement)

		# 	# Update swing radius based on what's shown on-screen
		# 	update_swing_radius()
		# 	var frog_pos = get_global_transform().xform(Vector2.ZERO)
		# 	var swing_vec = frog_pos - swing_pivot_position
		# 	swing_radius = swing_vec.length()


		swing_angular_speed += 1 / swing_radius * gravity * cos(swing_angle) * delta

		# Add some dampening to the swinging. Equivalent to speed being halved every second.
		swing_angular_speed *= pow(0.5, delta)

		# Adjust swing angle based on swing speed
		swing_angle += swing_angular_speed * delta

		# === Uh oh. "When moving a KinematicBody2D, you should not set its position property directly."
		# Instead of the direct position calculation, we can set velocity, and use move_and_collide
		velocity = Vector2.DOWN.rotated(swing_angle) * swing_angular_speed * swing_radius
		var collision_info = move_and_collide(velocity * delta)
		if collision_info:
			print_debug('Collide while swinging with ', collision_info.collider.name)
			swing_angular_speed *= -0.95
			# TODO: ^^^ Add some dampening since not every collision is perfectly elastic
	else:
		# Set X velocity based on user input
		# TODO: maybe do this differently? give the frog a little X momentum?
		velocity.x = user_direction.x * speed
		
		# Adjust Y velocity based on gravity and jump
		velocity.y += gravity * delta
		if jump_shorthop_countdown > 0:
			jump_shorthop_countdown -= delta
			if jump_shorthop_countdown <= 0 and not Input.is_action_pressed("jump"):
				jump_frame_countdown = 0
				velocity.y = jump_speed * shorthop_ratio
		if jump_frame_countdown > 0:
			jump_frame_countdown -= delta
			velocity.y = jump_speed
		velocity.y = max(min(velocity.y, 1200), -1200)
		velocity = move_and_slide(velocity, Vector2.UP)
		# Count down the hop sound timer, ensuring it never goes below 0.
		hop_sound_timer = max(hop_sound_timer - delta, 0)
		# Play sound effect when timer has expired and frog is walking on floor.
		if hop_sound_timer <= 0 && is_on_floor() && !is_zero(user_direction.x) && !is_zero(velocity.x):
			# Calculate new timer value, based on period as well as random variance.
			# This slight variance will hopefully make it sound more natural.
			# Let P and V be the period and variance, the minimum timer value will be P and the max will be P*(1+V)
			# In practice, with (P,V) = (0.2,0.1), the min will be 0.2 and the max will be 0.22
			hop_sound_timer = hop_sound_timer_period * (1 + rand_range(0, hop_sound_timer_period_variance))
			# Play sound effect.
			$HopSoundPlayer.play(0)
	pass

func update_anim():
	var facing_lock = $PlayerTongue.shooting
	if !facing_lock:
		if abs(user_direction.x) > 0.01:
			facing.x = user_direction.x
		facing.y = 0
		$Sprite.flip_h = facing.x < 0
	pass

# This function is used when the player shoots out their tongue
# to determine what direction it should travel in.
func get_tongue_direction():
	var tdir = user_direction
	# Block out tongueing down (positive Y dir'n)
	# If we're currently going to tongue down by any amount...
	if tdir.y > 0:
		# Remove the tongue's vertical component so it goes either
		# left or right
		tdir.y = 0
	if tdir.length_squared() < 0.01:
		tdir = facing
	if tdir.length_squared() < 0.01:
		tdir = Vector2.RIGHT
	
	return tdir.normalized()

func _physics_process(delta):
	update()
	get_input()
	do_movement(delta)

	# Factored out jump decision to avoid duplicating code.
	var do_jump = false
	if Input.is_action_just_pressed("jump"):
		if $PlayerTongue.swinging:
			do_jump = true
		else:
			if is_on_floor():
				do_jump = true
	if do_jump:
		# If the player is currently swinging, break them out of their swing.
		if $PlayerTongue.swinging:
			stop_swing()
		# Set jump timers to cause frog to jump.
		jump_frame_countdown = jump_length
		jump_shorthop_countdown = shorthop_length
		$JumpSoundPlayer.play(0)
	update_anim()
	if Input.is_action_just_pressed("tongue"):
		if $PlayerTongue.swinging:
			stop_swing()
		else:
			emit_signal("tongue_start", get_tongue_direction())

func die():
	print_debug("ded")
	get_tree().reload_current_scene()

func collect_star_piece(star_piece):
	# Increment star piece counter
	star_piece_count += 1
	print("Star piece count: ", star_piece_count)
	# Play sound
	$CollectStarPieceSoundPlayer.play(0)
	# Delete star piece
	star_piece.queue_free()

func _on_PlayerTongue_tongue_swing(global_tongue_position):
	swing_pivot_position = global_tongue_position
	start_swing()
	pass # Replace with function body.
