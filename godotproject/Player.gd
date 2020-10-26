extends KinematicBody2D

signal tongue_start
signal tongue_stop

export (int) var speed = 200
export (int) var jump_speed = -500
export (int) var gravity = 1200
export (float) var jump_length = 10 / 60.0
export (float) var shorthop_length = 6 / 60.0
export (float) var shorthop_ratio = 0.6

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

func start_swing():
	# Calculate initial angle and radius
	var frog_pos = get_global_transform().xform(Vector2.ZERO)
	var swing_vec = frog_pos - swing_pivot_position
	swing_radius = swing_vec.length()
	swing_angle = swing_vec.angle() # Angle from positive X-axis to swing vector
	var swing_dir_vec = swing_vec.rotated(PI/2)
	var dotprod = swing_dir_vec.dot(velocity)
	if abs(dotprod)<  0.01 or swing_radius < 0.01:
		swing_angular_speed = 0
	else:
		swing_angular_speed = dotprod / abs(dotprod) * pow(abs(dotprod), 0.5) / max(1, swing_radius)
	print_debug('Tongue:',swing_pivot_position,'\nFrog:',frog_pos,'\nRadius:',swing_radius,'\nAngle:',swing_angle,'\nAng. Speed:',swing_angular_speed)

func stop_swing():
	# Convert swinging angular momentum into player velocity
	velocity = Vector2.DOWN.rotated(swing_angle) * swing_angular_speed * swing_radius
	print_debug('Stop swing: Velocity=',velocity)
	emit_signal("tongue_stop")

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
	if $PlayerTongue.swinging:
		var tgt = Vector2.DOWN.rotated(swing_angle) * swing_angular_speed * 100
		draw_line(Vector2(0,0), tgt, Color(1,0,0))

func do_movement(delta):
	if $PlayerTongue.swinging:
		swing_angular_speed += 1 / swing_radius * gravity * cos(swing_angle) * delta
		swing_angular_speed *= pow(0.5, delta)
		# swing_angular_speed = max(min(swing_angular_speed, 10), -10)
		swing_angle += swing_angular_speed * delta
		var new_pos = swing_pivot_position + Vector2.RIGHT.rotated(swing_angle) * swing_radius
		# print_debug('Swing:', swing_angular_speed)
		position = new_pos
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
	pass

func update_anim():
	var facing_lock = !$PlayerTongue.idle
	if !facing_lock:
		if abs(user_direction.x) > 0.01:
			facing.x = user_direction.x
		facing.y = 0
		$Sprite.flip_h = facing.x < 0
	pass

func get_tongue_direction():
	var tdir = user_direction
	if tdir.length_squared() < 0.01:
		tdir = facing
	if tdir.length_squared() < 0.01:
		tdir = Vector2.RIGHT
	
	return tdir.normalized()

func _physics_process(delta):
	update()
	get_input()
	do_movement(delta)

	if Input.is_action_just_pressed("jump"):
		if $PlayerTongue.swinging:
			stop_swing()
			jump_frame_countdown = jump_length
			jump_shorthop_countdown = shorthop_length
		else:
			if is_on_floor():
				jump_frame_countdown = jump_length
				jump_shorthop_countdown = shorthop_length
	update_anim()
	if Input.is_action_just_pressed("tongue"):
		if $PlayerTongue.swinging:
			stop_swing()
		else:
			emit_signal("tongue_start", get_tongue_direction())

func die():
	print_debug("ded")
	get_tree().reload_current_scene()


func _on_PlayerTongue_tongue_swing(global_tongue_position):
	swing_pivot_position = global_tongue_position
	start_swing()
	pass # Replace with function body.
