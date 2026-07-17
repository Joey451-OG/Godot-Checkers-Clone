extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var base_array := [7, 8, 9]
	
	#print(base_array)
	#
	#base_array.append(_return_array())
	#
	#print(base_array)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _return_array() -> Array[int]:
	return [1, 2, 3]
