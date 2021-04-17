extends Node
enum State {
	NORMAL,
	RECORD,
	PLAYBACK
}
export (State) var state
export (String, FILE) var filepath

var press_list = []
var press_list_playback_index = 0
var current_state = {}
var playback_complete = false

func _save_to_disk():
	# Convert scores to JSON
	var json_data = JSON.print(press_list)
	# Save to disk
	var file = File.new()
	file.open(filepath, File.WRITE)
	if !file.is_open():
		printerr("Unable to open save file " + filepath)
		return
	file.store_string(json_data)
	print("Inputs saved.")
	file.close()

func _load_from_disk():
	# Load from disk
	var file = File.new()
	file.open(filepath, File.READ)
	if !file.is_open():
		printerr("Unable to open save file " + filepath)
		return
	var json_data = file.get_as_text()
	file.close()
	# Convert scores from JSON
	var json_result = JSON.parse(json_data)
	if json_result.error != OK or typeof(json_result.result) != TYPE_ARRAY:
		printerr("Error loading scores from file")
		return
	press_list = json_result.result

func _ready():
	if state == State.PLAYBACK:
		_load_from_disk()

func _physics_process(_delta):
	if state == State.RECORD and Input.is_action_just_pressed("menu"):
		_save_to_disk()
		state = State.NORMAL

func reset():
	press_list_playback_index = 0
	current_state = {}
	playback_complete = false

func get_input(frame_num):
	var user_direction = Vector2()
	var jump_pressed = false
	var jump_held = false
	var tongue_pressed = false
	var tongue_held = false
	match state:
		State.NORMAL, State.RECORD:
			var l = Input.is_action_pressed("walk_left")
			var r = Input.is_action_pressed("walk_right")
			var u = Input.is_action_pressed("look_up")
			var d = Input.is_action_pressed("look_down")
			user_direction.x = 0
			if l:
				user_direction.x -= 1
			if r:
				user_direction.x += 1
			user_direction.y = 0
			if u:
				user_direction.y -= 1
			if d:
				user_direction.y += 1
				
			jump_pressed = Input.is_action_just_pressed("jump")
			jump_held = Input.is_action_pressed("jump")
			tongue_pressed = Input.is_action_just_pressed("tongue")
			tongue_held = Input.is_action_pressed("tongue")
		State.PLAYBACK:
			while press_list_playback_index < len(press_list) and \
				press_list[press_list_playback_index][0] <= frame_num:
				var cpli = press_list[press_list_playback_index]
				current_state[cpli[1]] = cpli[2]
				press_list_playback_index += 1
			if press_list_playback_index >= len(press_list):
				playback_complete = true
			if len(current_state) > 0:
				user_direction = str2var("Vector2"+current_state['user_direction'])
				jump_pressed = current_state['jump_pressed']
				jump_held = current_state['jump_held']
				tongue_pressed = current_state['tongue_pressed']
				tongue_held = current_state['tongue_held']
	if state == State.RECORD:
		var new_state = {
			'user_direction': user_direction,
			'jump_pressed': jump_pressed,
			'jump_held': jump_held,
			'tongue_pressed': tongue_pressed,
			'tongue_held': tongue_held,
		}
		for key in new_state.keys():
			var prev = null
			var curr = new_state[key]
			if key in current_state:
				prev = current_state[key]
			if prev != curr:
				# Add to button press list
				press_list.append([frame_num, key, curr])
		current_state = new_state
	return [user_direction, jump_pressed, jump_held, tongue_pressed, tongue_held]
