extends Area2D

const DEFAULT_START = Vector2(-150, 0)
const DEFAULT_END = Vector2(150, 0)

export var Start: Vector2 = DEFAULT_START
export var End: Vector2 = DEFAULT_END

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("SetSawPosition")
	pass # Replace with function body.

func SetSawPosition():
	get_node("SawBlade/StartPos").position = Start
	get_node("SawBlade/EndPos").position = End
	$SawBlade.init()

