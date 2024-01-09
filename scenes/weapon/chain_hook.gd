extends Node2D
class_name ChainHook

@onready var chain = %Chain
@onready var hook = %Hook
@onready var state_chart = %StateChart
@onready var hook_sprite = %HookSprite

@onready var player: Player = get_parent()

@export var reach: int = 256
@export var speed: int = 200


signal release_chain

func _on_idle_state_entered():
	hook.set_deferred("monitorable", false)
	hook.set_deferred("monitoring", false)
	hook.set_deferred("visible", false)
	hook.position = Vector2.ZERO
	chain.points[1] = Vector2.ZERO

func fire():
	state_chart.send_event("player_shoots")


func _on_firing_state_entered():
	hook.monitorable = true
	hook.monitoring = true
	hook.visible = true
	hook_sprite.look_at(hook.global_position + player.facing_direction)
	$FireSound.play()
	$ChainLoop.play()

func _on_firing_state_exited():
	$ChainLoop.stop()

func force_release():
	state_chart.send_event("player_misses")

func _on_firing_state_physics_processing(delta):
	if hook.position.length() < reach:
		hook.position += speed * delta * player.facing_direction
		chain.points[1] = hook.position
	else:
		release_chain.emit()
		state_chart.send_event("player_misses")


func _on_hook_area_entered(area):
	if area is Enemy:
		hook.global_position = area.global_position
		chain.points[1] = hook.position
		state_chart.send_event("enemy_hit")
		$ElectricLoop.play()


func _on_hook_body_entered(body):
	if body is Terrain:
		release_chain.emit()
		state_chart.send_event("player_misses")
		$HitDirt.play()

## SHOCKING LOGIC
# just keep the chain in place until the enemy dies or the player releases
# (latter one is already handled by force_release)

func _on_hook_area_exited(area):
	if area is Enemy:
		release_chain.emit()
		state_chart.send_event("player_misses")
		$ElectricLoop.stop()



