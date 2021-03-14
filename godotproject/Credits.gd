extends Node2D

var inhibit_pause = true
var inhibit_hud = true

var hor_speed = 0
var vert_speed = 0
var rot_speed = 0.5

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	hor_speed = rng.randf_range(-1.0, 1.0)
	vert_speed = rng.randf_range(-1.0, 1.0)

func _process(_delta):
	if($Sprite.position.x > 660 or $Sprite.position.x < -20):
			hor_speed = -1 * hor_speed
			rot_speed = -1 * rot_speed
	if($Sprite.position.y > 600 or $Sprite.position.y < -20):
			vert_speed = -1 * vert_speed
			rot_speed = -1 * rot_speed
	
	$Sprite.position.x += hor_speed
	$Sprite.position.y += vert_speed
	$Sprite.rotation_degrees += rot_speed
