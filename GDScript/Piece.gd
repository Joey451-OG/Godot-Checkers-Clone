class_name Piece extends Node2D

enum COLOR {BLACK, RED}
const CHIP_ICONS = {
	COLOR.BLACK : Vector2i(3, 0),
	COLOR.RED : Vector2i(2, 0)
}
const KING_CHIP_ICONS = {
	COLOR.BLACK : Vector2i(4, 1),
	COLOR.RED : Vector2i(3, 1)
}

'''
King row: 
	When a man reaches the farthest row forward, 
	known as the kings row or crown head, it becomes a king.
	- Wikipedia
	
	Player rows  : [5, 7] -> 0
	Oponent rows : [0, 2] -> 7
'''
var _piece_icon : Vector2i
var _king_row : int
var _isKing : bool :
	set(value):
		if value == true:
			self._piece_icon = KING_CHIP_ICONS[self.team]
		else:
			self._piece_icon = CHIP_ICONS[self.team]
		
		_isKing = value
	
		trigger_icon_update()

var team : COLOR
var tile_map : Array[TileMapLayer]
var cord_normal : Vector2i
var cord : Vector2i : 
	set(value):
		# clean up cell with old cord value
		tile_map[2].erase_cell(cord)
		tile_map[3].erase_cell(cord)
		
		cord = value
		_normalize_cord()
		_check_for_king_row()
		trigger_icon_update()

var isSelected : bool = false:
	set(value):
		isSelected = value
		_update_highlight()


@warning_ignore("shadowed_variable")
func _init(isRed: bool, cord: Vector2i, tile_map: Array[TileMapLayer]):
	if isRed: 
		self.team = COLOR.RED 
		self._piece_icon = CHIP_ICONS[COLOR.RED]
	else: 
		self.team = COLOR.BLACK
		self._piece_icon = CHIP_ICONS[COLOR.BLACK]
	
	self.tile_map = tile_map
	self.cord = cord
	
	self._isKing = false
	
	_normalize_cord()
	
	if self.cord_normal.y in range(0, 3):
		self._king_row = 7
	
	if self.cord_normal.y in range(5, 7): # techinically overkill but more readable
		self._king_row = 0
	
	trigger_icon_update()

func _check_for_king_row():
	if cord_normal.y == _king_row:
		_isKing = true
	
func _update_highlight():
	if isSelected:
		tile_map[3].set_cell(cord, 0, Vector2i(2, 1))
	else:
		tile_map[3].erase_cell(cord)

func _normalize_cord():
	# IMPORTANT variable from main.gd:
	var board_origin := Vector2i(4, 2)
	
	cord_normal = Vector2i(cord.x - board_origin.x, cord.y - board_origin.y)

func get_isKing() -> bool:
	return _isKing

func get_piece_icon() -> Vector2i:
	return _piece_icon

func trigger_icon_update() -> void:
	self.tile_map[2].erase_cell(self.cord)
	self.tile_map[2].set_cell(self.cord, 0, self._piece_icon)
