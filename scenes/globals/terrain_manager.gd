extends Node

signal destroy_block(pos)
signal block_destroyed

var terrain: Terrain

func _on_terrain_collision(pos):
	destroy_block.emit(pos)
	block_destroyed.emit()

func has_tile(pos):
	return terrain.has_tile(pos)

func has_solid_tile(pos):
	return terrain.has_solid_tile(pos)

func map_position(pos):
	return terrain.local_to_map(pos)
