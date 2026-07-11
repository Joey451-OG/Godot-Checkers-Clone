extends Node2D

# renderer var	
@export var tile_map: Array[TileMapLayer]
@export var isDebugOn: bool = false

# shared
var isPlayerRed : bool = true
var black_pieces : Array[Piece]
var red_pieces : Array[Piece]
var isPlayerTurn : bool
var player_pieces : Array[Piece]
var op_pieces: Array[Piece]

# process globals
var current_piece_index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# is the player red?
	isPlayerTurn = not isPlayerRed
	
	_renderer(isPlayerRed)
	
	if isPlayerRed:
		player_pieces = red_pieces
		op_pieces = black_pieces
	else:
		player_pieces = black_pieces
		op_pieces = red_pieces
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# moving the pieces
	'''
	Stratigy:
		1. Dectect if a player clicks on their piece
		2. Highlight piece
		3. Show avalible moves for that piece
		4. If player clicks on an avalible move, move piece
		5. Else deselect and unhightlight piece 
	'''
	
	if Input.is_action_pressed("Select"):
		# step 1
		var tile_clicked := _get_tile_cord()
		var piece_index = _search_player_pieces(tile_clicked)
		
		# step 2
		_validate_piece(piece_index)
		
		# step 3
		
		# step 4
		# for now, every move is avalible
		if piece_index == null: # hack for now until step 3 is done
			_move_piece(tile_clicked)
		
		 
func _move_piece(location: Vector2i) -> void:
	'''
	3 steps for moving a piece:
		1. De-highlight the current position
		2. Erase piece
		3. Draw new piece to the board
		4. Update piece location
	'''
	
	# step 1
	player_pieces[current_piece_index].isSelected = false
	
	# step 2
	tile_map[2].erase_cell(player_pieces[current_piece_index].cord)
	
	# step 3
	var player_icon : Vector2i
	
	if isPlayerRed:
		player_icon = Vector2i(2, 0)
	else:
		player_icon = Vector2i(3, 0)
	
	tile_map[2].set_cell(location, 0, player_icon)
	
	# step 4
	player_pieces[current_piece_index].cord = location
	

func _validate_piece(piece_index) -> void:
	# both pieces are null, return
	if current_piece_index == null and piece_index == null:
		return
	
	# the same piece has been selected make sure it's selected and return
	if current_piece_index == piece_index:
		player_pieces[piece_index].isSelected = true
		return
	
	if current_piece_index == null:
		current_piece_index = piece_index
		player_pieces[piece_index].isSelected = true
		return
	
	# the current piece index isn't valid, return
	if piece_index == null:
		return

	# piece_index is different from current_piece_index, update
	# note: this only changes the current piece, it doesn't move the it
	player_pieces[current_piece_index].isSelected = false
	player_pieces[piece_index].isSelected = true
	current_piece_index = piece_index

func _get_tile_cord() -> Vector2i: 
	var local_cord = to_local(get_global_mouse_position())
	return tile_map[0].local_to_map(local_cord)

func _search_player_pieces(tile: Vector2i) -> Variant:
	for i in range(len(player_pieces)):
		if player_pieces[i].cord == tile:
			return i
	
	# peice not found, return null
	return null
	
func _renderer(isPlayerRed: bool):
	# draw background
	var bgk_tile: Vector2i = Vector2i(0, 1)
	var square_red := Vector2i(0, 0)
	var square_white := Vector2i(1, 0)
	var red_player := Vector2i(2, 0)
	var black_player := Vector2i(3, 0)
	var board_border := Vector2i(4, 0)
	var board_origin := Vector2i(4, 2)
	
	for x in range(18):
		for y in range(12):
			tile_map[0].set_cell(Vector2i(x, y), 0, bgk_tile)
	
	# >[!NOTE]
	# the screen is 18x12 tiles (1280 x 960 px at 4x zoom)
	
	# draw game board
	
	# main game board
	for x in range(board_origin.x, board_origin.x + 8):
		for y in range(board_origin.y, board_origin.y + 8):
			if isDebugOn: 
				print_debug("(%d, %d)" % [x, y])
			
			if (x + y) % 2 == 0:
				tile_map[1].set_cell(Vector2i(x, y), 0, square_white)
			else:
				tile_map[1].set_cell(Vector2i(x, y), 0, square_red)

	# border (Gonna deal with this later)
	#tile_map[1].set_cell(Vector2i(4, 1), 0, board_border)
	
	# place pecies
	# oponent
	for x in range(board_origin.x, board_origin.x + 8):
		for y in range(board_origin.y, board_origin.y + 3):
			if (x + y) % 2 != 0:
				var current_cord := Vector2i(x, y)
				if isPlayerRed:
					black_pieces.append(Piece.new(
						false, 
						current_cord, 
						tile_map
					))
					
					tile_map[2].set_cell(current_cord, 0, black_player)
				else:
					red_pieces.append(Piece.new(
						true, 
						current_cord, 
						tile_map
					))
					
					tile_map[2].set_cell(current_cord, 0, red_player)
					
	# player (always starts at the bottom on the board [highest y cord])
	for x in range(board_origin.x, board_origin.x + 8):
		for y in range(board_origin.y + 5, board_origin.y + 8):
			if (x + y) % 2 != 0:
				var current_cord := Vector2i(x, y)
				if not isPlayerRed:
					black_pieces.append(Piece.new(
						false, 
						current_cord, 
						tile_map
					))
					tile_map[2].set_cell(current_cord, 0, black_player)
				else:
					red_pieces.append(Piece.new(
						true, 
						current_cord, 
						tile_map
					))
					tile_map[2].set_cell(current_cord, 0, red_player)
