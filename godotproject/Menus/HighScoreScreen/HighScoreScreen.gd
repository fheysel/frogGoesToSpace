extends MarginContainer

export (Font) var sub_font
export (Color) var sub_color
export (Font) var sub_fancy_font
export (Color) var sub_fancy_color

enum State {
	HIDDEN,
	INITIAL_DISPLAY,
	THONK,
	FINAL_SOUND,
	WAIT_FOR_PRESS
}

onready var hsc := $CenterContainer/VBoxContainer/HighScoresContainer
onready var level_label := $CenterContainer/VBoxContainer/LevelLabel

var all_level_data = {}
var current_level = null
var current_level_data = null
var load_scene_after_high_score = null
var current_state = State.HIDDEN
var display_level_data = null
var final_idx = -1
var current_idx = -1

func active():
	return current_state != State.HIDDEN

func close():
	_change_state(State.HIDDEN)
	$ThonkBigSFX.stop()
	$ThonkSmallSFX.stop()

func show_level(level_name, countdown, next_scene_path = null):
	# Load this level's data
	_change_level(level_name, countdown)
	# Set our next scene properly. If nothing was provided, go to title screen next.
	self.load_scene_after_high_score = next_scene_path
	# Wait for user to close high score screen.
	_change_state(State.WAIT_FOR_PRESS)

func end_of_level(level_name, stars, time, countdown, next_scene_path):
	# Set up everything needed to proceed properly
	load_scene_after_high_score = next_scene_path
	# Load this level's data
	_change_level(level_name, countdown)
	# Create 'display_level_data' array - do a deep copy so we can do whatever we want to it
	# We will use it for animating.
	display_level_data = current_level_data.duplicate(true)
	var score = _calculate_score(stars, time, countdown)
	var dict = {'stars':stars, 'time':time, 'score':score}
	# Adjust current_level_data to have the current high score added to it
	final_idx = _add_score_to_current_level(dict)
	if final_idx == -1:
		_change_state(State.FINAL_SOUND)
		return
	# Save to disk
	_save_to_disk()
	# Set up everything required to animate the score coming in.
	display_level_data.append(dict)
	current_idx = 5
	_display_score_data(display_level_data, current_idx)
	_change_state(State.INITIAL_DISPLAY)

func _change_state(state):
	# If the state has a timer, start it.
	if state == State.INITIAL_DISPLAY:
		$InitialTimer.start()
	elif state == State.THONK:
		$ThonkTimer.start()
	elif state == State.FINAL_SOUND:
		$FinalSoundTimer.start()
	current_state = state

func _step_thonk_animation():
	var current = display_level_data[current_idx]
	display_level_data.remove(current_idx)
	current_idx -= 1
	display_level_data.insert(current_idx, current)
	if current_idx != 5 and len(display_level_data) > 5:
		display_level_data.pop_back()
	_display_score_data(display_level_data, current_idx)
	# This looks kinda funky, but it'll play the following notes:
	# C D E G c
	# It should sound nicer the higher of a place you get.
	# Get 1st place to try it out :)
	var rate = [2,3.0/2,5.0/4,9.0/8,1][current_idx]
	$ThonkSmallSFX.stop()
	$ThonkSmallSFX.pitch_scale = rate
	$ThonkSmallSFX.play()
	if current_idx <= final_idx:
		_change_state(State.FINAL_SOUND)

func _play_final_sound():
	# Don't play sound if we didn't get on the scoreboard
	if final_idx != -1:
		# Play sound of score settling into place
		$ThonkBigSFX.play()
	_change_state(State.WAIT_FOR_PRESS)

# This function is unit testable
func _compare_scores(new, old):
	return new['score'] > old['score']

# This function is unit testable
func _add_score_to_current_level(dict):
	var target_i = -1
	for i in range(len(current_level_data)):
		var test_i = len(current_level_data)-1-i
		var test_dict = current_level_data[test_i]
		if _compare_scores(dict, test_dict):
			target_i = test_i
		else:
			break
	if target_i != -1:
		current_level_data.insert(target_i, dict)
		current_level_data.pop_back()
	return target_i

# This function is unit testable
func _calculate_score(stars, time, countdown):
	var time_inv = time if countdown else max(2*60+30 - time, 0)
	return stars * 1000 + (floor(time_inv * 60) * 1000 / 1800)

func _change_level(name, countdown):
	if current_level and current_level_data:
		# Make sure we've saved our current level data to disk.
		# (In case we updated it and didn't persist it before).
		# We need to do this now because this will properly deal with the
		# "current_level_data".
		_save_to_disk()
	# Now we can adjust current_level and current_level_data as we need.
	var difficulty_str = "Hard"
	if Global.difficulty == Global.DIFFICULTY.EASY_MODE_e:
		difficulty_str = "Easy"
	current_level = "%s - %s" % [name, difficulty_str]
	if current_level in all_level_data:
		current_level_data = all_level_data[current_level]
	else:
		# We have to create a new set of level data for this level.
		current_level_data = []
		for i in range(5):
			# Make some fake high scores
			var stars = max(0, 2-i)
			var time = (3*60 - 15 * i) if countdown else (90 + 15 * i)
			var score = _calculate_score(stars,time,countdown)
			current_level_data.append({'stars':stars, 'time':time, 'score':score})
	level_label.text = current_level
	_display_score_data(current_level_data)

func _display_score_data(score_data, user_i = -1):
	# Remove previously-existing labels from the HighScoresContainer
	for i in range(hsc.get_child_count()-1, 3, -1):
		if hsc.get_child_count() > i:
			var child = hsc.get_child(i)
			if child == null:
				continue
			child.queue_free()
	# Always make 6 rows of labels, but don't put the #6
	# text in the 6th label, and if we don't have enough score data,
	# don't put any text in the labels in the last row.
	for i in range(6):
		var font = sub_font
		var color = sub_color
		# Show the user's score in a different colour/font
		if i == user_i:
			font = sub_fancy_font
			color = sub_fancy_color

		# Number
		var num_lb := Label.new()
		num_lb.align = Label.ALIGN_CENTER
		num_lb.add_font_override("font", font)
		num_lb.add_color_override("font_color", color)
		if i != 5:
			num_lb.text = "#%d" % [i+1]
		hsc.add_child(num_lb)
		# Stars
		var star_lb := Label.new()
		star_lb.align = Label.ALIGN_CENTER
		star_lb.add_font_override("font", font)
		star_lb.add_color_override("font_color", color)
		if i != 5 or len(score_data) >= 6:
			star_lb.text = "×%d" % score_data[i]['stars']
		hsc.add_child(star_lb)
		# Time
		var time_lb := Label.new()
		time_lb.align = Label.ALIGN_CENTER
		time_lb.add_font_override("font", font)
		time_lb.add_color_override("font_color", color)
		if i != 5 or len(score_data) >= 6:
			time_lb.text = Global.format_time(score_data[i]['time'])
		hsc.add_child(time_lb)
		# Score
		var score_lb := Label.new()
		score_lb.align = Label.ALIGN_CENTER
		score_lb.add_font_override("font", font)
		score_lb.add_color_override("font_color", color)
		if i != 5 or len(score_data) >= 6:
			score_lb.text = "%06d" % score_data[i]['score']
		hsc.add_child(score_lb)

func _ready():
	# Load "all_level_data" from disk.
	_load_from_disk()

func _process(_delta):
	self.visible = (current_state != State.HIDDEN)
	if current_state == State.HIDDEN:
		pass
	elif current_state == State.WAIT_FOR_PRESS:
		if Input.is_action_pressed("jump") \
		or Input.is_action_pressed("menu") \
		or Input.is_action_pressed("tongue"):
			Global.fade_to_scene(load_scene_after_high_score)

func _get_save_path():
	return "user://scores.json"

func _save_to_disk():
	# Put data from current_level_data into all_level_data
	if current_level and current_level_data:
		all_level_data[current_level] = current_level_data
	# Convert scores to JSON
	var json_data = JSON.print(all_level_data)
	# Save to disk
	var file = File.new()
	file.open(_get_save_path(), File.WRITE)
	if !file.is_open():
		printerr("Unable to open save file " + _get_save_path())
		return
	file.store_string(json_data)
	file.close()

func _load_from_disk():
	# Load from disk
	var file = File.new()
	file.open(_get_save_path(), File.READ)
	if !file.is_open():
		printerr("Unable to open save file " + _get_save_path())
		return
	var json_data = file.get_as_text()
	file.close()
	# Convert scores from JSON
	var json_result = JSON.parse(json_data)
	if json_result.error != OK or typeof(json_result.result) != TYPE_DICTIONARY:
		printerr("Error loading scores from file")
		return
	all_level_data = json_result.result

func _on_ThonkTimer_timeout():
	if current_state == State.THONK:
		_step_thonk_animation()
		$ThonkTimer.start()

func _on_InitialTimer_timeout():
	if current_state == State.INITIAL_DISPLAY:
		_change_state(State.THONK)

func _on_FinalSoundTimer_timeout():
	if current_state == State.FINAL_SOUND:
		_play_final_sound()
