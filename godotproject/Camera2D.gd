extends Camera2D

var smooth_zoom = 1
var target_zoom = 1

const ZOOM_SPEED = 1

func _process(delta):
	smooth_zoom = lerp(smooth_zoom, target_zoom, ZOOM_SPEED * delta)
	if smooth_zoom != target_zoom:
		set_zoom(Vector2(smooth_zoom, smooth_zoom))

func small_shake():
	$ScreenShake.start(0.1, 15, 4, 0)

