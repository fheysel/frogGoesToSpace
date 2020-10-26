extends RigidBody2D

signal tongue_swing

export (float) var shoot_speed = 600
export (float) var max_shoot_dist = 250
export (float) var max_swing_dist = 100

var velocity = Vector2.ZERO
var reset_position = false

var shoot_vec = Vector2.ZERO
var idle = true
var shooting = false
var swinging = false

var tongue_to_surface = null
var tongue_to_frog = null

# Called when the node enters the scene tree for the first time.
func _ready():
	start_idle()

func start_idle():
	print_debug('idle')
	idle = true
	shooting = false
	swinging = false
	$CollisionShape2D/Sprite.visible = false
	$CollisionShape2D.disabled = true
	reset_position = true

func handle_idle(delta):
	velocity = Vector2.ZERO
	reset_position = true

func start_shoot(dirn):
	print_debug('shoot')
	idle = false
	shooting = true
	swinging = false
	$CollisionShape2D/Sprite.visible = true
	$CollisionShape2D.disabled = false
	reset_position = false
	shoot_vec = dirn * shoot_speed

func handle_shoot(delta):
	velocity = shoot_vec
	if position.length_squared() >= max_shoot_dist * max_shoot_dist:
		# We didn't hit anything. Stop shooting.
		start_idle()

func start_swing(body):
	print_debug('swing')
	idle = false
	shooting = false
	swinging = true
	$CollisionShape2D/Sprite.visible = true
	$CollisionShape2D.disabled = false
	
	tongue_to_surface = PinJoint2D.new()
	tongue_to_surface.set_node_a(self.get_path())
	tongue_to_surface.set_node_b(body.get_path())
	tongue_to_surface.set_softness(0.01)
	self.add_child(tongue_to_surface)
	
	tongue_to_frog = DampedSpringJoint2D.new()
	tongue_to_frog.set_node_a(self.get_path())
	tongue_to_frog.set_node_b(self.get_parent().get_path())
	tongue_to_frog.set_damping(0.9)
	tongue_to_frog.set_length(150)
	tongue_to_frog.set_rest_length(100)
	tongue_to_frog.set_stiffness(20.0)
	self.add_child(tongue_to_frog)

func handle_swing(delta):
	velocity = Vector2.ZERO

func _physics_process(delta):
	velocity = 0
	if idle:
		handle_idle(delta)
	elif shooting:
		handle_shoot(delta)
	elif swinging:
		handle_swing(delta)
	else:
		print_debug('Invalid tongue state. Resetting...')
		idle = true
		reset_position = true
	set_linear_velocity(velocity)

func _integrate_forces(state):
	if reset_position:
		state.transform = Transform2D(0, self.get_parent().get_global_transform().xform(Vector2.ZERO))
		state.linear_velocity = Vector2()
		reset_position = false


func _on_Player_tongue_start(facing):
	if idle:
		start_shoot(facing)
	pass # Replace with function body.

func _on_TongueCollisionBody_body_entered(body):
	if shooting:
		start_swing(body)
