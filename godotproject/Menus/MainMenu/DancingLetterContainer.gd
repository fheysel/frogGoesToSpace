extends HBoxContainer

export (String) var text
export (Font) var main_text_font
export (bool) var menu_open

var letter_tbs = []
var time = 0
var menu_open_anim_done = false

func jump_func(x,t):
	var sin_param = -(x)*0.01 + t*6/4*PI - PI
	if sin_param >= PI:
		sin_param = PI + (sin_param - PI) * 1.8
	if sin_param < 0 or sin_param >= 2*PI:
		return 0
	var s = sin(sin_param)
	return s * 0.3 if s < 0 else s

func _ready():
	for letter in text:
		var letter_tb := Label.new()
		letter_tb.align = Label.ALIGN_CENTER
		letter_tb.add_font_override("font", main_text_font)
		# letter_tb.add_color_override("font_color", color)
		letter_tb.text = letter
		letter_tb.anchor_bottom = 1
		letter_tb.rect_min_size.y = 100
		add_child(letter_tb)
		letter_tbs.append(letter_tb)

func _process(delta):
	if !menu_open:
		menu_open_anim_done = false
	if !menu_open_anim_done:
		time += delta
	if menu_open and time >= 4:
		menu_open_anim_done = true
		time = 0
	time = fmod(time, 4)
	for ltb in letter_tbs:
		ltb.rect_min_size.y = 100 + 60*jump_func(ltb.margin_left, time)
