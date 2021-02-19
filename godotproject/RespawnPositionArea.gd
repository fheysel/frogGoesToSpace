extends Area2D

# We keep track of whether or not the player could
# currently be inside our collision, based on the
# entered/exited events.
var player_inside := false
var player = null

func _process(_delta):
	if !player_inside:
		return
	# We use the overlaps_body function to double-check
	# that the player is still inside of us.
	if player and overlaps_body(player):
		player.update_respawn_position()
	else:
		# If the player somehow exited without the event,
		# then we mark them as not inside.
		player_inside = false

func _on_RespawnPositionArea_body_entered(body):
	if !Global.is_player(body):
		return
	player = body
	player_inside = true

func _on_RespawnPositionArea_body_exited(body):
	if !Global.is_player(body):
		return
	player_inside = false
