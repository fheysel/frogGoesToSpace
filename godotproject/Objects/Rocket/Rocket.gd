extends Node2D

var blastOff = false
var frog_on_board = false
var speed = 80 

var trauma_level = 0 # counter to see how many jets are on

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if(blastOff):
		self.position.y -= speed * delta


func activateJet():
	if trauma_level == 0:
		trauma_level += 1
		$Jet1.visible = true
		$Jet1.play("launch_jetstream")
		$JetBoom.play(0)
	elif trauma_level == 1:
		trauma_level += 1
		$Jet2.visible = true
		$Jet2.play("launch_jetstream")
		$JetBoom.play(0)
		blastOff = true
	

func _on_door_close_animation_finished():
	frog_on_board = true
	$Door/glow.stop()
	go_to_space()
	
func go_to_space():
	pause_mode = Node.PAUSE_MODE_PROCESS # Allow the rocket to keep moving
	Global.cutscene_inhibits_pause = true # Inhibit opening the menu
	Global.cutscene_pauses_game = true # Pause everything else
	var player = Global.get_player()
	player.visible = false
	player.zoom_out(4)
	player.trigger_screen_shake(10, 30, 8, 1)
	$JetBoom.play()
	speed = 250
	$Timer.start()
	
func _on_Timer_timeout():
	# Rocket has now left
	if frog_on_board:
		$EOL._on_EOL_body_entered(Global.get_player())
	else:
		var player = Global.get_player()
		player.die()
		
