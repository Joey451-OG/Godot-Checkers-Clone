class_name Piece extends Node2D

enum COLOR {BLACK, RED}

'''
King row: 
	When a man reaches the farthest row forward, 
	known as the kings row or crown head, it becomes a king.
	- Wikipedia
	
	Player rows  : [5, 7] -> 0
	Oponent rows : [0, 2] -> 7
'''
var _king_row : int
var _isKing : bool

var team : COLOR
var tile_map : Array[TileMapLayer]
var cord_normal : Vector2i
var cord : Vector2i : 
	set(value):
		cord = value
		_check_for_king_row()
		_normalize_cord()

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
	
	self._isKing = false
	
	if self.cord.y in range(0, 3):
		self._king_row = 7
	
	if self.cord.y in range(5, 7): # techinically overkill but more readable
		self._king_row = 0

func _check_for_king_row():
	if cord.y == _king_row:
		_isKing = true
		# add crown effect here eventually
	
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
