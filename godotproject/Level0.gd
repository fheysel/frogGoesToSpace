extends Node2D

const STAR := 4

export (PackedScene) var Star

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("setup_tiles")
	
func setup_tiles():
	# This function takes the level and replaces all the "active tiles" ie 
	# stars, spikes etc with an instance of their corresponding scene  
	
	var cells = $TileMap.get_used_cells()
	for cell in cells:
		var index = $TileMap.get_cell(cell.x, cell.y)
		match index:
			STAR:
				create_instance_from_tilemap(cell, Star, self)
				

func create_instance_from_tilemap(coord:Vector2, prefab:PackedScene, parent:Node2D): #, offset:Vector2 = Vector2.ZERO)
	# This is where the actual replacement happens. 
	
	$TileMap.set_cell(coord.x, coord.y, -1) # Set the cell to be empty
	var pf = prefab.instance() # Create an instance of the scene
	pf.position = $TileMap.map_to_world(coord)  # Set its position
	parent.add_child(pf) # Add it to the level's scene
