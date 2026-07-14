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
var opponent_pieces: Array[Piece]
var moves : Array[Vector2i]

const BOARD_SIZE : int = 8

# process globals
var current_piece_index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# is the player red?
	isPlayerTurn = not isPlayerRed
	
	_renderer(isPlayerRed)
	
	if isPlayerRed:
		player_pieces = red_pieces
		opponent_pieces = black_pieces
	else:
		player_pieces = black_pieces
		opponent_pieces = red_pieces
	
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
		6. De-render moves 
	'''
	
	if Input.is_action_pressed("Select"):
		# step 1
		var tile_clicked := _get_tile_cord()
		var piece_index = _search_player_pieces(tile_clicked)
		
		# step 2
		_validate_piece(piece_index)
		
		# step 3
		if piece_index != null:
			moves = _calculate_valid_moves(piece_index)
			_render_moves(moves)
		
		# step 4
		if piece_index == null:
			if tile_clicked in moves:
				_move_piece(tile_clicked)
			else:
				# clear the current selection
				player_pieces[current_piece_index].isSelected = false
				_render_moves(moves, true)
				moves.clear()
				
		# step 6 is completed at the beginning of _calculate_valid_moves()


func _calculate_valid_moves(piece_index: int) -> Array[Vector2i]:
	var current := player_pieces[piece_index]
	var left := Vector2i(current.cord.x - 1, current.cord.y - 1)
	var right := Vector2i(current.cord.x + 1, current.cord.y - 1)
	var player_obsticals : Array
	var opponent_obsticals : Array
	var valid_moves : Array[Vector2i]
	
	# Derender previous moves and clear
	_render_moves(moves, true)
	moves.clear()
	
	if not current.get_isKing():
		# check for any obsitcals in Vector2i(x - 1, y - 1) and 
		# Vector2i(x + 1, y - 1), these are the two possible moves if open
		# if an obsitical is capturable, recursively check all "jump spaces"
		
		# check un-capturable obsticals (god I need a better name)
		player_obsticals.append(_search_player_pieces(left))
		player_obsticals.append(_search_player_pieces(right))
		
		# check capturable obsticals
		opponent_obsticals.append(_search_opponent_pieces(left))
		opponent_obsticals.append(_search_opponent_pieces(right))
		
		# check for empty spots
		for i in range(len(player_obsticals)):
			# remember, just becase there isn't a player piece there
			# doesn't mean there's NOT an opponent piece there
			if player_obsticals[i] == null and opponent_obsticals[i] == null:
				# left at index 0, right at index 1
				if i == 0 and _validate_potential_move(left):
					valid_moves.append(left)
				elif i == 1 and _validate_potential_move(right):
					valid_moves.append(right)
				# no reason to continue since we know there isn't an oppenent piece
				continue 
			
			# TODO: Impliment capturing checks
			# It might be more effient to hand off to a seperate function here
			if opponent_obsticals[i] != null:
				if i == 0 and _validate_potential_move(left):
					# left
					valid_moves.append(_calculate_capture_moves(left, Vector2i(-1, -1)))
				elif i == 1 and _validate_potential_move(right):
					# right
					valid_moves.append(_calculate_capture_moves(right, Vector2i(1, -1)))
			continue

		
	else:
		# King logic
		# basically the same except a bit more complicated
	
		# TODO: Impliment king logic here
		pass
	
	return valid_moves

func _calculate_capture_moves(cord: Vector2i, direction_vector: Vector2i) -> Array[Vector2i]:
	var check_cord := Vector2i(cord.x + direction_vector.x, cord.y + direction_vector.y)
	var opponent_obstical_index = _search_opponent_pieces(check_cord)
	var valid_moves : Array[Vector2i]
	
	if opponent_obstical_index == null:
		opponent_obstical_index = _search_opponent_pieces(Vector2i(check_cord + direction_vector))
		
		if opponent_obstical_index != null:
			valid_moves.append(_calculate_capture_moves(
				opponent_pieces[opponent_obstical_index].cord,
				direction_vector
			))
	return valid_moves
	

func _valid_king_moves(piece_index : int):
	var current := player_pieces[piece_index]
	var left := Vector2i(current.cord.x - 1, current.cord.y - 1)
	var right := Vector2i(current.cord.x + 1, current.cord.y - 1)
	var left_king := Vector2i(current.cord.x - 1, current.cord.y + 1)
	var right_king := Vector2i(current.cord.x + 1, current.cord.y + 1)
	
	
	

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

func _validate_potential_move(move: Vector2i) -> bool:
	var move_normal = _normalize_to_board_cord(move)
	if move_normal.x < 0 or move_normal.x >= BOARD_SIZE:
		return false
	if move_normal.y < 0 or move_normal.y >= BOARD_SIZE:
		return false
	
	return true

func _get_tile_cord() -> Vector2i: 
	var local_cord = to_local(get_global_mouse_position())
	return tile_map[0].local_to_map(local_cord)

func _normalize_to_board_cord(cord : Vector2i) -> Vector2i:
	# IMPORTANT VARIABLE FROM _renderer()
	var board_origin := Vector2i(4, 2)
	return Vector2i(cord.x - board_origin.x, cord.y - board_origin.y)


func _search_player_pieces(tile: Vector2i) -> Variant:
	for i in range(len(player_pieces)):
		if player_pieces[i].cord == tile:
			return i
	
	# peice not found, return null
	return null

func _search_opponent_pieces(tile: Vector2i) -> Variant:
	for i in range(len(opponent_pieces)):
		if opponent_pieces[i].cord == tile:
			return i
	
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
	for x in range(board_origin.x, board_origin.x + BOARD_SIZE):
		for y in range(board_origin.y, board_origin.y + BOARD_SIZE):
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
	for x in range(board_origin.x, board_origin.x + BOARD_SIZE):
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
				
	black_pieces.append(Piece.new(
		false,
		Vector2i(3 + board_origin.x, 4 + board_origin.y),
		tile_map
	))
	tile_map[2].set_cell(Vector2i(3 + board_origin.x, 4 + board_origin.y), 0, black_player)
					
	# player (always starts at the bottom on the board [highest y cord])
	for x in range(board_origin.x, board_origin.x + BOARD_SIZE):
		for y in range(board_origin.y + 5, board_origin.y + BOARD_SIZE):
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

func _render_moves(moves: Array[Vector2i], erase: bool = false):
	var move_hint = Vector2i(1, 1)
	for m in moves:
		if not erase:
			tile_map[3].set_cell(m, 0, move_hint)
		else:
			tile_map[3].erase_cell(m)
