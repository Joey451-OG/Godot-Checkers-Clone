class_name Piece extends Node2D

enum COLOR {BLACK, RED}

var team : COLOR
var tile_map : Array[TileMapLayer]
var cord : Vector2i

var isSelected : bool = false:
	set(value):
		isSelected = value
		_update_highlight()


@warning_ignore("shadowed_variable")
func _init(isRed: bool, cord: Vector2i, tile_map: Array[TileMapLayer]):
	if isRed: 
		self.team = COLOR.RED 
	else: 
		self.team = COLOR.BLACK
	
	self.cord = cord
	self.tile_map = tile_map

func _update_highlight():
	if isSelected:
		tile_map[3].set_cell(cord, 0, Vector2i(2, 1))
	else:
		tile_map[3].erase_cell(cord)
