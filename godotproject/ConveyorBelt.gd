extends StaticBody2D

export var speed = 20

func _ready():
	constant_linear_velocity.x = speed

func _process(delta):
	#set("region_rect", speed*delta)
	$Sprite.region_rect.position.x -= 50 * delta
	
