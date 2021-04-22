extends Node

var time : float = 0
var max_time : float = 9 * 60 + 59 + (59/60)
var counting_down := false

func _ready():
	reset(false)

func _process(delta):
	if counting_down:
		time -= delta
		time = max(time, 0)
		# If the player has run out of time, rocket takes off without them.
		if time <= 0:
			var rocket = get_tree().current_scene.get_node("Rocket")
			if rocket == null:
				push_error("Unable to get rocket object - level won't end!")
			else:
				rocket.go_to_space()
	else:
		# Countup timer
		time += delta
		# Cap timer at whatever the max_time is (9:59:59)
		time = min(time, max_time)

func reset(should_count_down, count_down_value = 1):
	counting_down = should_count_down
	if counting_down:
		time = count_down_value
		if time == null:
			push_error("Level is countdown but doesn't define initial time - using 1s")
			time = 1
	else:
		# Countup timer, start at 0
		time = 0
