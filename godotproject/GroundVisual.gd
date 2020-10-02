extends Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var visual = $"."
	var sb = StaticBody2D.new()
	var collision = CollisionPolygon2D.new()
	collision.polygon = visual.polygon
	sb.add_child(collision)
	$".".add_child(sb)
