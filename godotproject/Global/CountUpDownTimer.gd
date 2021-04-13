extends Node

var time : float = 0
var max_time : float = 9 * 60 + 59 + (59/60)

func _ready():
	reset()

func _process(delta):
	if Global.level_uses_countdown_timer():
		time -= delta
		time = max(time, 0)
		# If the player has run out of time, kill them.
		if time <= 0:
			var player = Global.get_player()
			if player == null:
				push_error("Unable to get player object - player won't die")
			else:
				player.die()
	else:
		# Countup timer
		time += delta
		# Cap timer at whatever the max_time is (9:59:59)
		time = min(time, max_time)

func reset():
	if Global.level_uses_countdown_timer():
		time = Global.get_current_scene_property("countdown_timer_initial_count")
		if time == null:
			push_error("Level is countdown but doesn't define initial time - using 1s")
			time = 1
	else:
		# Countup timer, start at 0
		time = 0
