extends Node

@onready var parent = get_parent()
var tween: Tween

func _ready():
	if !parent:
		push_error("Movement component should have a parent")
	if !("moving" in parent):
		push_error("Parent should have a boolean called moving")

func move(desired_position):
	parent.moving = true
	tween = create_tween()
	tween.tween_property(parent, "position", desired_position, 16.0/parent.speed)
	tween.finished.connect( func(): parent.moving = false)

func stop():
	parent.moving = false
	tween.stop()
