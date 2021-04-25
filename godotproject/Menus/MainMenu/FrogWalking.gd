extends CanvasLayer

signal done_walking

export (float) var frog_velocity
export (bool) var menu_open

var inhibit_hud = true
onready var init_position = $FakeFrog.position

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("frog_hop")

func _process(_delta):
	$FakeFrog.visible = !menu_open

func _physics_process(delta):
	if !menu_open:
		$FakeFrog.position.x += frog_velocity * delta

func reset():
	$FakeFrog.position = init_position
	$AnimationPlayer.play("frog_hop")

func _on_Area2D_area_entered(area):
	if area == $FakeFrog/Area2D:
		emit_signal("done_walking")
