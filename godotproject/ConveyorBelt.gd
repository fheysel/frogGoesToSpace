extends StaticBody2D

export var speed = 20

var tongue_stick_velocity

func _ready():
	constant_linear_velocity.x = speed
	tongue_stick_velocity = constant_linear_velocity

func _process(delta):
	#set("region_rect", speed*delta)
	$Sprite.region_rect.position.x -= (speed/2) * delta
	
