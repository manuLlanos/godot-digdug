extends Node
# for usage of global sounds

var sounds: Dictionary = {}

func _ready():
	for child: AudioStreamPlayer in get_children():
		sounds[child.name] = child

func play(sound: String):
	if sound in sounds:
		sounds[sound].play()
