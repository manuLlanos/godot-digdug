extends Area2D
class_name Player

@export var speed: int = 40


@onready var smooth_movement = %SmoothMovement
@onready var state_chart = %StateChart
@onready var chain_hook = %ChainHook
@onready var animation_tree = %AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var sprite = %Sprite2D

signal terrain_collision(pos)
signal death

const TILE_SIZE = 64

var moving_tween: Tween
var moving: bool = false

var facing_direction := Vector2.RIGHT
var direction := Vector2.ZERO

# should've used the tween signal + moving boolean when making pacman but oh well
func _ready():
	animation_tree.active = true
	Globals.player_pos = position
	terrain_collision.connect(TerrainManager._on_terrain_collision)
	chain_hook.release_chain.connect(release_chain)


## normal state logic
func _on_normal_state_entered():
	playback.travel("moving")

func _on_normal_state_physics_processing(_delta):
	Globals.player_pos = position
	if Input.is_action_just_pressed("shoot"):
		state_chart.send_event("player_shoot")
		return
	if moving:
		return
	
	direction = handle_move_input()
	##moving  animation and sprite flipping
	animation_tree.set("parameters/moving/blend_position", direction)
	if signf(direction.x) != 0:
		sprite.flip_h = signf(direction.x) == -1
	
	if direction != Vector2.ZERO:
		facing_direction = direction
		var desired_position = position + direction * TILE_SIZE
		
		# dont allow the player to exit the grid
		if !TerrainManager.has_tile(desired_position):
			return
		
		if TerrainManager.has_solid_tile(desired_position):
			terrain_collision.emit(desired_position)
		
		smooth_movement.move(desired_position)

## shooting state logic
# when key is released, miss or enemy hit with chain dies, return to normal state
# maybe use a signal for this rather than processing
func _on_shooting_state_entered():
	playback.travel("shooting")
	chain_hook.fire()

func release_chain():
	state_chart.send_event("player_release_chain")

func _on_shooting_state_physics_processing(_delta):
	if Input.is_action_just_released("shoot"):
		chain_hook.force_release()
		release_chain()


func handle_move_input():
	var dir := Vector2.ZERO
	if Input.is_action_pressed("left") || Input.is_action_pressed("right"):
		dir.x += Input.get_action_raw_strength("right") - Input.get_action_strength("left")
	elif Input.is_action_pressed("down") || Input.is_action_pressed("up"):
		dir.y += Input.get_action_raw_strength("down") - Input.get_action_strength("up")
	return dir

func hit():
	#quick way to play random death sound, i just want to get the game done
	$DeathSounds.get_children().pick_random().play()
	state_chart.send_event("death")

## dead logic
func _on_dead_state_entered():
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	death.emit()
	chain_hook.force_release()
	playback.travel("death")
