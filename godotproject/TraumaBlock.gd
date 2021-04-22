extends Area2D

var trauma_level = 0 # ensures the screen shakes is triggered only once ie 
					 # when the jet turns on


func _on_Node2D_body_exited(body):
	if Global.is_player(body):
		if trauma_level == 0:
			trauma_level = trauma_level + 1
			body.trigger_screen_shake() # start a screen shake
			get_parent().activateJet() # turn on jet particles

	
