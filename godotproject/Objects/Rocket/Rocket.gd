extends Node2D

var blastOff = false
var speed = 15 

var trauma_level = 0 # counter to see how many jets are on

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if(blastOff):
#		$Sprite.position.y -= speed * delta
#		$Jet1.position.y -= speed * delta
		self.position.y -= speed * delta

func activateJet():
	if trauma_level == 0:
		trauma_level += 1
		$Jet1.emitting = true
		$JetBoom.play(0)
	elif trauma_level == 1:
		trauma_level += 1
		$Jet2.emitting = true
		$JetBoom.play(0)
		blastOff = true
		$Timer.start()
		


func _on_Timer_timeout():
	speed = 80
	$JetBoom.play()
	
