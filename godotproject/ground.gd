extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var visual = $Visual
	var collision = CollisionPolygon2D.new()
	collision.polygon = visual.polygon
	$".".add_child(collision)
