extends Area2D
class_name Rock

@export var speed: int = 80

@onready var animation_player = %AnimationPlayer
@onready var smooth_movement = %SmoothMovement
@onready var sprite = %Sprite2D

const TILE_SIZE = 64

var active: bool = false
var falling: bool = false
var moving: bool = false

func _ready():
	TerrainManager.block_destroyed.connect(check_below)

func _physics_process(_delta):
	if !falling:
		return
	if moving:
		return
	
	var direction = Vector2(0, 1)
	var desired_position = position + direction * TILE_SIZE
	if TerrainManager.has_solid_tile(desired_position) or !TerrainManager.has_tile(desired_position):
		falling = false
		animation_player.play("destroy")
		AudioManager.play("RockCrash")
	else:
		smooth_movement.move(desired_position)

func check_below():
	if active:
		return
	var tile_below_pos = position + Vector2.DOWN * TILE_SIZE
	if !TerrainManager.has_solid_tile(tile_below_pos):
		active = true
		shake()

func shake():
	animation_player.play("shake")
	AudioManager.play("RockRumble")

func fall():
	sprite.frame = 1
	falling = true


func _on_area_entered(area):
	if "hit" in area:
		AudioManager.play("Crush")
		area.hit()
	if area is Enemy:
		Globals.score += 50
