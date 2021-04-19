extends Node

export (PackedScene) var attract_scene

var inhibit_pause = true
var inhibit_hud = true

enum State {
	MAIN_SCREEN,
	CONTROLS,
	DIFFICULTY_MENU,
	VIDEO
}
var state = State.MAIN_SCREEN
var next_state = State.MAIN_SCREEN
var video_node = null

func set_node_paused(x, pause):
	x.pause_mode = PAUSE_MODE_STOP if pause else PAUSE_MODE_INHERIT

func transition_update_ui():
	var video = next_state == State.VIDEO
	$ViewportLayer/AttractModeViewportContainer.visible = video
	$ViewportLayer/MarginContainer.visible = video
	set_node_paused($FrogWalking, video)
	set_node_paused($MainMenuLayer, video)
	set_node_paused($ViewportLayer, !video)
	if video:
		# We can't seem to pause stuff properly... so instead we just
		# dynamically create and remove the attract scene from the tree.
		# This also saves having to try and reset it.
		video_node = attract_scene.instance()
		$ViewportLayer/AttractModeViewportContainer/Viewport.add_child(video_node)
		video_node.get_node("Player/PlayerInputHandler").connect("playback_complete", self, "_on_VideoPlayer_finished")
	else:
		if state == State.VIDEO:
			$FrogWalking.reset()
			$ViewportLayer/AttractModeViewportContainer/Viewport.remove_child(video_node)
		var open = next_state != State.MAIN_SCREEN
		$FrogWalking.menu_open = open
		$DancingTextLayer/MarginContainer/CenterContainer/DancingLetterContainer.menu_open = open
		match next_state:
			State.MAIN_SCREEN:
				$MainMenuLayer/AnimationPlayer.play("start_text")
			State.CONTROLS:
				$MainMenuLayer/AnimationPlayer.play("controls")
			State.DIFFICULTY_MENU:
				$MainMenuLayer/AnimationPlayer.play("difficulty")
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
		State.CONTROLS:
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
			if pressed_fwd or pressed_bck:
				go_to_state(State.CONTROLS)
		State.CONTROLS:
			if pressed_fwd:
				go_to_state(State.DIFFICULTY_MENU)
			elif pressed_bck:
				go_to_state(State.MAIN_SCREEN)
		State.DIFFICULTY_MENU:
			if pressed_bck:
				go_to_state(State.CONTROLS)
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

