extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var priority = 0

onready var camera = get_parent()

func start(duration = 0.5, frequency = 15, _amplitude = 16, _priority = 1):
	if (priority >= self.priority):
		priority = _priority
		amplitude = _amplitude

		$Duration.wait_time = duration
		$Frequency.wait_time = 1 / float(frequency)
		$Duration.start()
		$Frequency.start()

		_new_shake()


func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)

	$ShakeTween.interpolate_property(camera, "offset", camera.offset, rand, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

func _reset():
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Frequency.wait_time, TRANS, Tween.EASE_OUT)
	$ShakeTween.start()

	priority = 0


func _on_Frequency_timeout():
	_new_shake()
	

func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
