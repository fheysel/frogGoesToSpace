extends Node2D

signal tongue_swing

export (float) var shoot_speed = 600
export (float) var max_shoot_dist = 250
export (float) var max_swing_dist = 100

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
	$TongueCollisionArea/CollisionShape2D/Sprite.visible = false
	position = Vector2.ZERO

func handle_idle(delta):
	pass

func start_shoot(dirn):
	idle = false
	shooting = true
	swinging = false
	shoot_direction = dirn

func handle_shoot(delta):
	$TongueCollisionArea/CollisionShape2D/Sprite.visible = true
	# Advance tongue in direction
	position += shoot_direction * shoot_speed * delta
	if position.length_squared() >= max_shoot_dist * max_shoot_dist:
		# We didn't hit anything. Stop shooting.
		start_idle()

func handle_swing(delta):
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
	pass # Replace with function body.


func _on_TongueCollisionArea_body_entered(body):
	if shooting:
		idle = false
		shooting = false
		swinging = true
		emit_signal("tongue_swing", get_global_transform().xform(Vector2.ZERO))
		$TongueCollisionArea/CollisionShape2D.disabled = true
