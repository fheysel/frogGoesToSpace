extends Node

var time : float = 0
var max_time : float = 9 * 60 + 59 + (59/60)

func _process(delta):
	time += delta
	# Cap timer at whatever the max_time is (9:59:59)
	time = min(time, max_time)

func reset():
	time = 0
