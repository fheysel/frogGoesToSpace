extends Area2D

var trauma_level = 0 # ensures the screen shakes is triggered only once ie 
					 # when the jet turns on

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Node2D_body_exited(body):
	if body.has_method("collect_star_piece"): # ie we know its the player
		if trauma_level == 0:
			trauma_level = trauma_level + 1
			body.trigger_screen_shake() # start a screen shake
			get_parent().activateJet() # turn on jet particles

	
