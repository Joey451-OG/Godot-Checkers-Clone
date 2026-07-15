class_name Move extends Node2D

var from_cord : Vector2i
var to_cord : Vector2i
var isCapture : bool
var captured_piece : Vector2i

@warning_ignore("shadowed_variable")
func _init(
	from_cord: Vector2i,
	to_cord: Vector2i,
	isCapture: bool
) -> void:
	self.from_cord = from_cord
	self.to_cord = to_cord
	self.isCapture = isCapture

func get_to_cord():
	return to_cord

func set_captured_piece(cord: Vector2i) -> void:
	assert(isCapture, "ERROR: Move.isCapture must be true!")
	self.captured_piece = cord
