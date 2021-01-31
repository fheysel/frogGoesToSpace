extends Area2D

const level0_start_postion :=  Vector2(121, 896)
const level1_start_postion := Vector2(121, 256)

var level_name = null

func _on_DeathPlane_body_entered(body):
	if  body.name == "Player":
		level_name = Global.get_current_scene_property('level_name')
		if level_name == "Morning Meadow":
			Global.fade_set_body_to_position(body, level0_start_postion)
		elif level_name == "The Big City":
			Global.fade_set_body_to_position(body, level1_start_postion)
		
		body.takeDamage(1)
		# Global.fade_to_scene("res://Level" + str(int(get_tree().current_scene.name)) + ".tscn")
