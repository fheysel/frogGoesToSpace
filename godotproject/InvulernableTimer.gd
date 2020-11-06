extends Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("timeout", get_parent(), "on_invulnerable_timeout")
	one_shot = true
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
