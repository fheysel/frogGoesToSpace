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
	# make player invisible so that it doesnt look like the rocket takes off without them
	var player = Global.get_player()
	player.visible = false
	go_to_space()
	
func go_to_space():
	speed = 250
	
	# Make sure both jets are on
	if !$Jet1.is_playing():
		print('hi')
		blastOff = true
		$Jet1.visible = true
		$Jet1.play("looping_stream")
	if !$Jet2.is_playing():
		blastOff = true
		$Jet2.visible = true
		print('hello')
		$Jet2.play("looping_stream")
		
	pause_mode = Node.PAUSE_MODE_PROCESS # Allow the rocket to keep moving
	Global.cutscene_inhibits_pause = true # Inhibit opening the menu
	Global.cutscene_pauses_game = true # Pause everything else
	var player = Global.get_player()
	player.zoom_out(4)
	player.trigger_screen_shake(10, 30, 8, 1)
	$JetBoom.play()
	$Timer.start()
	
	
func _on_Timer_timeout():
	# Rocket has now left
	if frog_on_board:
		$VictorySoundPlayer.play()
		$EOL._on_EOL_body_entered(Global.get_player())
	else:
		var player = Global.get_player()
		player.die()	
		

