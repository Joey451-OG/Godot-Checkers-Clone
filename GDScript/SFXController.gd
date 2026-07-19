extends AudioStreamPlayer
@export var wood_sounds : Array[AudioStreamMP3]
@export var crowned_sound : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_piece_crowned():
	stream = crowned_sound
	play()

func play_piece_move():
	var rand_index := randi() % len(wood_sounds)

	stream = wood_sounds[rand_index]
	play()


# signal entries
func _on_root_piece_moved() -> void:
	play_piece_move()


func _on_root_piece_crowned() -> void:
	play_piece_crowned()
