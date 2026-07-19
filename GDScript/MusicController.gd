extends AudioStreamPlayer

@export var music_files : Array[AudioStreamMP3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_finished()

func _on_finished():
	stream = music_files[randi() % len(music_files)]
	play()
