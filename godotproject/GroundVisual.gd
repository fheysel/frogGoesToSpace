extends Polygon2D

export (int, LAYERS_2D_PHYSICS) var phys_layer = 1
export (int, LAYERS_2D_PHYSICS) var phys_mask = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	var visual = $"."
	var sb = StaticBody2D.new()
	sb.collision_layer = phys_layer
	sb.collision_mask = phys_mask
	var collision = CollisionPolygon2D.new()
	collision.polygon = visual.polygon
	sb.add_child(collision)
	$".".add_child(sb)
