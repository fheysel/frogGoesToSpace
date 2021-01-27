extends Node2D

export (float) var left_bound;
export (float) var top_bound;
export (float) var right_bound;
export (float) var bottom_bound;
export (float) var margin;
export (NodePath) var player_nodepath;

# Make it so that the player doesn't hit against a floor when
# they fall into a bottomless pit
const fall_off_screen_amount := 300

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get camera node off of player
	var player = get_node(player_nodepath)
	var camera = player.get_node("Camera2D")
	# Set camera limit
	camera.limit_top = top_bound
	camera.limit_bottom = bottom_bound
	camera.limit_left = left_bound
	camera.limit_right = right_bound
	
	# Calculate space width and height
	var bounds_width = right_bound - left_bound
	var bounds_height = bottom_bound - top_bound
	# Create 4x StaticBody with CollisionShape
	var extents = [
		# x, y, w, h
		[left_bound, top_bound, margin, bounds_height + fall_off_screen_amount],
		[left_bound, top_bound, bounds_width, margin],
		[right_bound, bottom_bound, margin, bounds_height + fall_off_screen_amount],
		[right_bound, bottom_bound + fall_off_screen_amount, bounds_width, margin],
	]
	for extent in extents:
		var sb = StaticBody2D.new()
		var cs = CollisionShape2D.new()
		var csr = RectangleShape2D.new()
		csr.extents = Vector2(extent[2], extent[3])
		cs.shape = csr
		cs.transform = Transform2D(0, Vector2(extent[0], extent[1]))
		sb.add_child(cs)
		$".".add_child(sb)
	pass # Replace with function body.

