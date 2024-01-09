extends Area2D
class_name Enemy

const TILE_SIZE: int = 64

signal death

@export var max_speed: float = 35
var speed: float = max_speed

@onready var smooth_movement = %SmoothMovement
@onready var wander_timer = $WanderTimer
@onready var chase_timer = $ChaseTimer
@onready var state_chart = %StateChart
@onready var kill_timer = %KillTimer
@onready var animation_player = %AnimationPlayer
@onready var sprite = %Sprite2D

var direction: Vector2

var moving: bool = false 
var is_buried: bool = false

# current level determines speed, increasing difficulty
func _ready():
	max_speed = max_speed * (1 + (Globals.level-1)/20.0)
	speed = max_speed


func hit():
	state_chart.send_event("death")

func get_path_to_player():
	var map_pos: Vector2i = Vector2i(TerrainManager.map_position(position))
	var player_map_pos: Vector2i = Vector2i(TerrainManager.map_position(Globals.player_pos))
	var point_path: Array = Astargrid.get_path_array(map_pos, player_map_pos)
	return point_path

func get_dig_path_to_player():
	var map_pos: Vector2i = Vector2i(TerrainManager.map_position(position))
	var player_map_pos: Vector2i = Vector2i(TerrainManager.map_position(Globals.player_pos))
	var point_path: Array = AstargridNonSolid.get_path_array(map_pos, player_map_pos)
	return point_path

## WANDER LOGIC

func _on_wander_state_entered():
	animation_player.play("walk", -1, 0.8)
	speed = 0.8 * max_speed
	# the time the enemy will wander for before deciding to dig or chase
	wander_timer.wait_time = randf_range(5, 20)
	wander_timer.start()

func _on_wander_state_physics_processing(_delta):
	## for now keep it simple, simply choose a random direction and if it's
	## empty, move there
	if moving:
		return
	
	direction = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].pick_random()
	var desired_position: Vector2 = position + direction * TILE_SIZE
	
	sprite.flip_h = sign(direction.x) < 0
	
	
	if TerrainManager.has_solid_tile(desired_position) || !TerrainManager.has_tile(desired_position):
		return
	smooth_movement.move(desired_position)


func _on_wander_timer_timeout():
	# here put logic to decide between direct chase or digging
	if get_path_to_player():
		state_chart.send_event("can_reach_player")
	else:
		state_chart.send_event("cannot_reach_player")


## CHASE LOGIC
func _on_chase_state_entered():
	AudioManager.play("BugAlert")
	animation_player.play("walk", -1, 1.0)
	speed = max_speed
	chase_timer.stop()
	# time it will chase for until going back to wandering
	chase_timer.wait_time = randf_range(5, 15)
	chase_timer.start()

func _on_chase_state_physics_processing(_delta):
	if moving:
		return
	# find player location, move there tile by tile
	# use astargrid2d, new in godot 4, should make it easier
	# check if tileset system needs to be changed or not
	
	var point_path: Array = get_path_to_player()
	if !point_path:
		return
	if point_path.size() == 1:
		return
	
	var desired_pos: Vector2 = point_path[1] + Vector2(TILE_SIZE/2.0, TILE_SIZE/2.0)
	sprite.flip_h = sign(desired_pos.x - position.x) < 0
	smooth_movement.move(desired_pos)

func _on_chase_timer_timeout():
	state_chart.send_event("chase_timeout")


##DIG LOGIC
#go to player position directily "digging" through solid tiles
#when an open tile is reached
#if can reach player directly go to chase mode
# if not, return to wandering

func _on_dig_state_entered():
	AudioManager.play("Dig")
	animation_player.play("walk", -1, 0.5)
	speed = 0.5 * max_speed


func _on_dig_state_exited():
	AudioManager.play("DigOut")


func _on_dig_state_physics_processing(_delta):
	if moving:
		return
		
	
	var point_path: Array = get_dig_path_to_player()
	if !point_path:
		print("Cannot reach player??")
		return
	if point_path.size() == 1:
		print("Player already reached??")
		return
	
	var desired_pos: Vector2 = point_path[1] + Vector2(TILE_SIZE/2.0, TILE_SIZE/2.0)
	sprite.flip_h = sign(desired_pos.x - position.x) != 1
	smooth_movement.move(desired_pos)
	
	if !is_buried and TerrainManager.has_solid_tile(desired_pos):
		is_buried = true
	
	if is_buried and !TerrainManager.has_solid_tile(desired_pos):
		if get_path_to_player():
			state_chart.send_event("can_reach_player")
		else:
			state_chart.send_event("cannot_reach_player")


## STUN/KILL LOGIC
func _on_stunned_state_entered():
	animation_player.stop()
	# stop the movement tween and reset position to grid
	smooth_movement.stop()
	position = position.snapped(TILE_SIZE/2.0 * Vector2.ONE)


func _on_area_entered(area):
	if area is Hook:
		state_chart.send_event("hit_by_player")
		kill_timer.start()
		return
	if area is Player:
		area.hit()

func _on_area_exited(area):
	if area is Hook:
		kill_timer.stop()
		# if the player hit it, it should already have a path to it
		state_chart.send_event("stun_broken")

func _on_kill_timer_timeout():
	# killed by player, so play zap sound
	AudioManager.play("Zap")
	state_chart.send_event("death")


func _on_dead_state_entered():
	death.emit()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	AudioManager.play("BugDeath")
	animation_player.play("death", -1, 1.0)

