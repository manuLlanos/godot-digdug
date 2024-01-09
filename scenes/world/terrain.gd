extends TileMap
class_name Terrain



signal block_destroyed

func _ready():
	#for player: Player in get_tree().get_nodes_in_group("Player"):
		#player.terrain_collision.connect(destroy_block)
	TerrainManager.destroy_block.connect(destroy_block)
	
	Astargrid.configure(get_used_rect(), Vector2(64, 64))
	Astargrid.update()
	AstargridNonSolid.configure(get_used_rect(), Vector2(64, 64))
	AstargridNonSolid.update()
	# set solid cells
	## DO NOT UPDATE ANYMORE OR IT SETS EVERYTHING TO NON SOLID AGAIN :)
	# update should only be called when configuring the grid dimensions
	set_solid_cells()


func set_solid_cells():
	for point in get_used_cells(1):
		Astargrid.set_solid(point)

func destroy_block(pos):
	var block_pos = local_to_map(pos)
	erase_cell(1, block_pos)
	Astargrid.set_solid(block_pos, false)
	set_solid_cells()
	block_destroyed.emit()
	AudioManager.play("HitEarth")

func has_solid_tile(pos):
	var block_pos = local_to_map(pos)
	return get_cell_tile_data(1, block_pos) != null

func has_tile(pos):
	var block_pos = local_to_map(pos)
	for layer in range(get_layers_count()):
		if get_cell_tile_data(layer, block_pos) != null:
			return true
	return false


