extends KinematicBody2D

export (int) var speed = 200
export (int) var jump_speed = -500
export (int) var gravity = 1200
export (float) var jump_length = 10 / 60.0
export (float) var shorthop_length = 6 / 60.0
export (float) var shorthop_ratio = 0.6
export (float) var tongue_max_catch_dist = 150
export (float) var tongue_max_swing_dist = 100


var velocity = Vector2.ZERO
var jump_frame_countdown = 0
var jump_shorthop_countdown = 0

func get_input():
	velocity.x = 0
	if Input.is_action_pressed("walk_right"):
		velocity.x += speed
	if Input.is_action_pressed("walk_left"):
		velocity.x -= speed

func _physics_process(delta):
	get_input()
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
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_frame_countdown = jump_length
			jump_shorthop_countdown = shorthop_length

func die():
	print_debug("ded")
	get_tree().reload_current_scene()
