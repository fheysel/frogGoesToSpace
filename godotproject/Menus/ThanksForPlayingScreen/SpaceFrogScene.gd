extends Node2D

var hor_speed = 0
var vert_speed = 0
var rot_speed = 0.5

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var hdir = rng.randi_range(0, 1) * 2 - 1
	var vdir = rng.randi_range(0, 1) * 2 - 1
	hor_speed = rng.randf_range(0.3, 0.6) * hdir
	vert_speed = rng.randf_range(0.3, 0.6) * vdir
	$Sprite.position.x = rng.randf_range(0, 640)
	$Sprite.position.y = rng.randf_range(0, 200)

func _process(delta):
	if($Sprite.position.x > 640+20 or $Sprite.position.x < -20):
			hor_speed = -1 * hor_speed
			rot_speed = -1 * rot_speed
	if($Sprite.position.y > 512+20 or $Sprite.position.y < -20):
			vert_speed = -1 * vert_speed
			rot_speed = -1 * rot_speed
	
	$Sprite.position.x += hor_speed * delta * 60
	$Sprite.position.y += vert_speed * delta * 60
	$Sprite.rotation_degrees += rot_speed * delta * 60
