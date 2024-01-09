extends Node
# Singleton for all the enemies pathfinding, considering solid tiles

var astar_grid = AStarGrid2D.new()

func _ready():
	astar_grid.diagonal_mode  = AStarGrid2D.DIAGONAL_MODE_NEVER

func configure(region: Rect2i, cell_size: Vector2):
	astar_grid.region = region
	astar_grid.cell_size = cell_size
	update()

func update():
	astar_grid.update()

func set_solid(point: Vector2i, solid: bool = true):
	astar_grid.set_point_solid(point, solid)

func get_path_array(from: Vector2, to: Vector2):
	var point_path = astar_grid.get_point_path(Vector2i(from), Vector2i(to))
	return point_path
