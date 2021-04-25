extends Label

var counter = 0

func _process(delta):
	counter += delta
	counter = fmod(counter, 2)
	visible = counter < 1
