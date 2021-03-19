extends KinematicBody2D

const COLLECT_ID = 1

const FLOOR = Vector2(0, -1)
const SPEED = 3000
const MAX_VERTICAL_TRAVEL = 500
const MAX_HORIZONTAL_TRAVEL = 10000

enum STATE{
	idle_e,
	detected_player_e,
	attacking_player_e,
}

var velocity = Vector2(0, 0)
var horizontal_direction = 1
var horizontal_directional_distance = 0
var vertical_direction = 1
var vertical_directional_distance = 0

func _physics_process(delta):
	velocity.x = SPEED * delta * horizontal_direction
	velocity.y = SPEED * delta * vertical_direction * 0.7

	velocity = move_and_slide(velocity, FLOOR)
	horizontal_directional_distance += SPEED * delta
	vertical_directional_distance += SPEED * delta
	
	if horizontal_directional_distance > MAX_HORIZONTAL_TRAVEL:
		horizontal_direction *= -1
		$Orientation.scale.x *= -1
		horizontal_directional_distance = 0
	if vertical_directional_distance > MAX_VERTICAL_TRAVEL:
		vertical_direction *= -1
		vertical_directional_distance = 0

func _on_PlayerHitBoxArea_body_entered(body):
	if body.has_method("collect"):
		body.collect(self)

