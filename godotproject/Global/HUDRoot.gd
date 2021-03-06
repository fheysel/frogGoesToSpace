extends Control

onready var lb_life = $LeftPanel/HBoxContainer/LifeContainer/LifeCountLabel
onready var lb_star = $LeftPanel/HBoxContainer/StarContainer/StarCountLabel
onready var lb_time = $RightPanel/TimeCountLabel
onready var menu = $"/root/Global/InGameMenuLayer/InGameMenu"

var countup_timer = null

func _process(_delta):
	# Check if we should hide the HUD
	if Global.should_hide_hud():
		hide()
		return
	else:
		show()

	# Check if we should show or hide the transparent backing to the HUD elements
	# based on if the pause menu is open
	if menu.active():
		$StyleAnimationPlayer.play("inmenu")
	else:
		$StyleAnimationPlayer.play("ingame")

	# Get player from current scene
	var scene = get_tree().current_scene
	if scene:
		var player = scene.find_node("Player", false, true)
		if player:
			var health = player.health
			lb_life.text = str(health)
			var star = player.star_piece_count
			lb_star.text = str(star)
	if !Global.node_exists_in_tree(countup_timer):
		countup_timer = $"/root/CountUpDownTimer"
	if countup_timer:
		var time = countup_timer.time
		lb_time.text = Global.format_time(time)
