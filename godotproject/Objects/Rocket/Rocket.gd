extends Node2D


var trauma_level = 0 # counter to see how many jets are on

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func activateJet():
	if trauma_level == 0:
		trauma_level += 1
		$Jet1.emitting = true
	elif trauma_level == 1:
		trauma_level += 1
		$Jet2.emitting = true
