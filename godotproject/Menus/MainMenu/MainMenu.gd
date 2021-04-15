extends Node

var inhibit_pause = true
var inhibit_hud = true

enum State {
	MAIN_SCREEN,
	DIFFICULTY_MENU,
	VIDEO
}
var state = State.MAIN_SCREEN
var next_state = State.MAIN_SCREEN

func set_node_paused(x, pause):
	x.pause_mode = PAUSE_MODE_STOP if pause else PAUSE_MODE_INHERIT

func transition_update_ui():
	var video = next_state == State.VIDEO
	$VideoLayer/VideoPlayer.visible = video
	set_node_paused($FrogWalking, video)
	set_node_paused($MainMenuLayer, video)
	set_node_paused($VideoLayer, !video)
	if video:
		$VideoLayer/VideoPlayer.play()
	else:
		if state == State.VIDEO:
			$FrogWalking.reset()
		$VideoLayer/VideoPlayer.stop()
		var open = next_state == State.DIFFICULTY_MENU
		$FrogWalking.menu_open = open
		$DancingTextLayer/MarginContainer/CenterContainer/DancingLetterContainer.menu_open = open
		if open:
			$MainMenuLayer/AnimationPlayer.play("difficulty")
		else:
			$MainMenuLayer/AnimationPlayer.play("start_text")
	state = next_state

func start_transition():
	$FadeToBlackLayer/AnimationPlayer.play("transition")
	if next_state == State.VIDEO:
		set_node_paused($MainMenuLayer, true)

func go_to_state(next):
	next_state = next
	match state:
		State.MAIN_SCREEN:
			if next_state == State.VIDEO:
				# Fade to black, then transition
				start_transition()
			else:
				# Don't bother fading, just go straight there
				transition_update_ui()
		State.DIFFICULTY_MENU:
			transition_update_ui()
		State.VIDEO:
			start_transition()

func _ready():
	transition_update_ui()

func _process(_delta):
	# Don't handle inputs if we're fading
	if $FadeToBlackLayer/AnimationPlayer.is_playing():
		return
	var pressed_fwd = Input.is_action_just_pressed("ui_accept")
	var pressed_bck = Input.is_action_just_pressed("ui_cancel") or \
		Input.is_action_just_pressed("menu")
	match state:
		State.MAIN_SCREEN:
			if pressed_fwd:
				go_to_state(State.DIFFICULTY_MENU)
		State.DIFFICULTY_MENU:
			if pressed_bck:
				go_to_state(State.MAIN_SCREEN)
		State.VIDEO:
			if pressed_fwd or pressed_bck:
				go_to_state(State.MAIN_SCREEN)

func start_game():
	Global.fade_to_scene("res://Level0.tscn")

func _on_Easy_pressed():
	Global.difficulty = Global.DIFFICULTY.EASY_MODE_e
	start_game()

func _on_Hard_pressed():
	Global.difficulty = Global.DIFFICULTY.HARD_MODE_e
	start_game()

func _on_FrogWalking_done_walking():
	go_to_state(State.VIDEO)

func _on_VideoPlayer_finished():
	go_to_state(State.MAIN_SCREEN)

func _fade_complete():
	transition_update_ui()

