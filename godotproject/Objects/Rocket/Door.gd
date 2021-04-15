extends KinematicBody2D


var tongue_stick_velocity = Vector2(0, 0) # FIXME ideally should be get_parent().speed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#func _on_Door_body_entered(body):
#	if Global.is_player(body):
#		$door_open.play('open')
#		$AudioStreamPlayer2D.play()

func _on_door_open_animation_finished():
	$door_close.visible = true
	$door_open.visible = false
	$door_close.play('close')


func _on_Area2D_body_entered(body):
	if Global.is_player(body):
		$door_open.play('open')
		$AudioStreamPlayer2D.play()
