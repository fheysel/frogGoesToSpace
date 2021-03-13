extends Node2D

# Each level has to have a name in it now, this will be displayed on the high score screen
const level_name := "NASA HQ"

const SPIKE := 0
const STAR := 1

export (PackedScene) var Spike
export (PackedScene) var Star

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("setup_tiles")
	
func setup_tiles():
	# This function takes the level and replaces all the "active tiles" ie 
	# stars, spikes etc with an instance of their corresponding scene  
	
	var cells = $TileMap4.get_used_cells()
	for cell in cells:
		var index = $TileMap4.get_cell(cell.x, cell.y)
		match index:
			SPIKE:
				create_instance_from_tilemap(cell, Spike, self, Vector2(8, 12))
			STAR:
				create_instance_from_tilemap(cell, Star, self, Vector2(16,20))
				

func create_instance_from_tilemap(coord:Vector2, prefab:PackedScene, parent:Node2D, offset:Vector2 = Vector2.ZERO): 
	# This is where the actual replacement happens. 
	
	$TileMap4.set_cell(coord.x, coord.y, -1) # Set the cell to be empty
	var pf = prefab.instance() # Create an instance of the scene
	pf.position = $TileMap4.map_to_world(coord) + offset # Set its position
	parent.add_child(pf) # Add it to the level's scene
