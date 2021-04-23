extends Node2D


func play():
	$AnimatedSprite.visible = true
	$AnimatedSprite.play()
	$AudioStreamPlayer2D.play()


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.visible = false
