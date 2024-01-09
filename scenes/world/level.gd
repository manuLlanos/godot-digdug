extends Node2D

const TILE_SIZE = 64

var rock_scene: PackedScene = preload("res://scenes/world/rock.tscn")
var total_enemies: int = 0
@onready var terrain = %Terrain
@onready var player = %Player
@onready var ui = %UI

func _ready():
	TerrainManager.terrain = $Terrain
	player.death.connect(_on_player_death)
	for enemy: Enemy in get_tree().get_nodes_in_group("Enemies"):
		total_enemies +=1
		enemy.death.connect(_on_enemy_death)
	spawn_rocks()

func _on_player_death():
	Globals.lives -= 1
	await get_tree().create_timer(3).timeout
	if Globals.is_game_over:
		ui.show_game_over()
		await get_tree().create_timer(2).timeout
		Globals.reset()
	
	Globals.score = Globals.last_score
	get_tree().reload_current_scene()


func _on_enemy_death():
	Globals.score += 50
	total_enemies -= 1
	if total_enemies == 0:
		ui.show_level_won()
		Globals.score += 100 * Globals.level
		Globals.last_score = Globals.score
		await  get_tree().create_timer(2).timeout
		Globals.level += 1
		get_tree().reload_current_scene()

## spawn rocks randomly
# if a tile and the tile below it are solid, first tile has a 2% chance of spawning a rock
func spawn_rocks():
	# get all solid cells
	for point in terrain.get_used_cells(1):
		var pos: Vector2 = terrain.map_to_local(point)
		if !terrain.has_tile(pos + Vector2(0, TILE_SIZE)):
			continue
		if !terrain.has_solid_tile(pos + Vector2(0, TILE_SIZE)):
			continue
		if randf() < 0.02 + (Globals.level-1)/100.0:
			add_rock(pos)

func add_rock(pos: Vector2i):
	var rock = rock_scene.instantiate()
	rock.global_position = pos
	$Rocks.add_child(rock)

