extends Node2D

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

var swing_pivot_position = Vector2.ZERO

func start_swing():
	# Create tongue's PhysicsBody
	
	pass

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

func do_movement(delta):
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
	get_input()
	do_movement(delta)

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_frame_countdown = jump_length
			jump_shorthop_countdown = shorthop_length
	update_anim()
	if Input.is_action_just_pressed("tongue"):
		emit_signal("tongue_start", get_tongue_direction())
		pass

func die():
	print_debug("ded")
	get_tree().reload_current_scene()


func _on_PlayerTongue_tongue_swing(global_tongue_position):
	swing_pivot_position = global_tongue_position
	start_swing()
	pass # Replace with function body.
