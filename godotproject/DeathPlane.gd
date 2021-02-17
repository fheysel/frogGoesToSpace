extends Area2D


export (Vector2) var start_postion


var level_name = null

func _on_DeathPlane_body_entered(body):
	if  body.name == "Player":
		body.takeDamage(1)
		if !body.dead:
			Global.fade_set_body_to_position(body, start_postion)

