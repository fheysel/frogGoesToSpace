extends KinematicBody2D

const FLOOR = Vector2(0, -1)
const SPEED = 20000
const MAX_HORIZONTAL_TRAVEL = 100

var velocity = Vector2(0, 0)
var horizontal_direction = 1
var horizontal_directional_distance = 0

var attackDamage = 1
var object_scale = 0
var radius = 0

func _ready():
#	radius = $SawBlade/PlayerCollision.shape.radius
#	var collNode = get_node("PlayerCollision/CollisionShape2D")
	radius = $PlayerCollision/CollisionShape2D.shape.radius
	
func _process(delta):
	# moving the blade
	velocity.x = SPEED * delta * horizontal_direction
	velocity = move_and_slide(velocity, FLOOR)
	
	#rotating the sprite
	var rotation = velocity.x / radius
	rotation_degrees = int(rotation_degrees + rotation) % 360
	
	if is_on_wall():
		horizontal_direction *= -1

func _on_SawBladeArea_area_exited(area):
	horizontal_direction *= -1

func _on_PlayerCollision_body_entered(body):
	print(body)
	if (body.name == "Player"):
		body.takeDamage(attackDamage)
	pass # Replace with function body.
