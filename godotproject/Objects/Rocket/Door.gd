extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Door_body_entered(body):
	$door_open.play('open') # Replace with function body.

func _on_door_open_animation_finished():
	$door_close.visible = true
	$door_open.visible = false
	$door_close.play('close')# Replace with function body.
