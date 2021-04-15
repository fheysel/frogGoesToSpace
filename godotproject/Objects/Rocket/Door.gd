extends Area2D

var has_opened = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Door_body_entered(body):
	if Global.is_player(body):
		$door_open.play('open')
		$AudioStreamPlayer2D.play()

func _on_door_open_animation_finished():
	has_opened = true
	$door_close.visible = true
	$door_open.visible = false
	$door_close.play('close')
