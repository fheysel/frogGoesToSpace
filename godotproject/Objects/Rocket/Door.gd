extends KinematicBody2D


var tongue_stick_velocity = Vector2(0, -80) 
var door_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#func _on_door_open_animation_finished():
#	$door_close.visible = true
#	$door_open.visible = false
#	$door_close.play('close')


func _on_Area2D_body_entered(body):
	# Player is inside so close the door.
	if Global.is_player(body):
		$door_close.visible = true
		$door_open.visible = false
		$door_close.play('close')
		$AudioStreamPlayer2D.play()


func _on_outerDoorArea_body_entered(body):
	# Player is near the door so open it
	if Global.is_player(body):
		if !door_open: # Ensures that its a one shot animation
			door_open = true
			$door_close.visible = false
			$door_open.visible = true
			$glow.visible = true
			$door_open.play('open')
			$AudioStreamPlayer2D.play()
	
		
