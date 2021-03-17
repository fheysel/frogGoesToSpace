extends Node2D

const IDLE_DURATION = 1.0
const PLATFORM_WIDTH = 80

export var move_to = Vector2.RIGHT * PLATFORM_WIDTH # equivalent to 2 tile widths to the right
export var speed = 3.0

onready var platform = $Platform
onready var tween = $MoveTween

var follow = Vector2.ZERO

func _ready():
	print('hi')
	_init_tween()

func _init_tween():
	print('sup')
	var duration = move_to.length() / float(speed * PLATFORM_WIDTH)
	tween.interpolate_property(self, "follow", Vector2.ZERO, move_to, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, IDLE_DURATION)
	tween.interpolate_property(self, "follow", move_to, Vector2.ZERO, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, duration + IDLE_DURATION * 2)
	tween.start()
	
func _physics_process(_delta):
	platform.position = platform.position.linear_interpolate(follow, 0.075) # Gives some smoothing to the platform
	
