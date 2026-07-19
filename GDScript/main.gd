extends Node2D

# consts and enums
enum TURN  {BLACK, RED}
const BOARD_SIZE : int = 8
@onready var UI = $WinUiScene
@onready var CAMERA: Camera2D = $Camera2D

# signals
signal piece_moved
signal piece_crowned

# renderer var
@export var tile_map: Array[TileMapLayer]
@export var isDebugOn: bool = false

# shared
var isPlayerRed : bool = Globals.isPlayerOneRed
var black_pieces : Array[Piece]
var red_pieces : Array[Piece]
var player_pieces : Array[Piece]
var opponent_pieces: Array[Piece]
var moves : Array[Move]
var turn_direction_multiplier := 1


# process globals
var current_piece_index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UI.hide()
	UI.size = get_viewport().get_visible_rect().size
	UI.scale = Vector2(1 / CAMERA.zoom.x, 1 / CAMERA.zoom.y)
	
	_renderer()
	_two_player_change_turns()
	
	# hack: multiply turn_direction_multiplier by -1 to revert the turn switch for the first turn
	turn_direction_multiplier *= -1
	
	# not implimenting darker player goes first
	
	if isDebugOn:
		print_debug("Making last player piece a King")
		player_pieces[-1]._isKing = true
	
func _input(event: InputEvent) -> void:
	_check_game_end()
	
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
	if event.is_action_pressed("Select"):
		# step 1
		var tile_clicked := _get_tile_cord()
		var piece_index = _search_player_pieces(tile_clicked)
		
		# step 2
		_validate_piece(piece_index)
		
		# step 3
		if piece_index != null:
			moves = _calculate_valid_moves(piece_index)
			_render_moves(MOVE_get_to_cord(moves))
		
		# step 4
		if piece_index == null:
			var tmp_to_cord := MOVE_get_to_cord(moves)
			var tmp_isCapture := MOVE_get_isCapture(moves)
			
			var playerHasMoved := false
			for i in range(len(tmp_to_cord)): 
				if tile_clicked == tmp_to_cord[i] and not tmp_isCapture[i]:
					_move_piece(tile_clicked)
					playerHasMoved = true
				if tile_clicked == tmp_to_cord[i] and tmp_isCapture[i]:
					_move_piece(tile_clicked)
					_capture_piece(moves[i])
					
					# player has captured a piece, check for more caputres
					
					# clear out the old moves
					_render_moves(MOVE_get_to_cord(moves), true)
					moves.clear()
					
					# look for new moves and remove any non-caputring ones
					moves = _calculate_valid_moves(current_piece_index)
					
					var tmp_capture : Array[Move]
					for m in moves:
						if m.isCapture:
							tmp_capture.append(m)
					
					moves.assign(tmp_capture)
					
					# display caputre moves
					_render_moves(MOVE_get_to_cord(moves))
					
					# re-select the current piece
					player_pieces[current_piece_index].isSelected = true
					
					# if len(moves) > 0, return to skip the clear step
					if len(moves) > 0:
						return
					else:
						# multi-jump has ended, end the move
						playerHasMoved = true
			
			# clear the current selection
			if current_piece_index != null:
				player_pieces[current_piece_index].isSelected = false
				_render_moves(MOVE_get_to_cord(moves), true)
				moves.clear()
			
			# this needs to be last so that we can clear the selection above
			if playerHasMoved:
				isPlayerRed = not isPlayerRed
				_two_player_change_turns()
		# step 6 is completed at the beginning of _calculate_valid_moves()

func MOVE_get_to_cord(given_moves: Array[Move]) -> Array[Vector2i]:
	var ret : Array[Vector2i] 
	for m in given_moves:
		ret.append(m.to_cord)
	
	return ret

func MOVE_get_isCapture(given_moves: Array[Move]) -> Array[bool]:
	var ret : Array[bool]
	for m in given_moves:
		ret.append(m.isCapture)
	
	return ret

func _calculate_valid_moves(piece_index: int) -> Array[Move]:
	var current := player_pieces[piece_index]
	var left := current.cord + (Vector2i(-1, -1) * turn_direction_multiplier)
	var right := current.cord + (Vector2i(1, -1) * turn_direction_multiplier)
	var player_obsticals : Array
	var opponent_obsticals : Array
	var valid_moves : Array[Move]
	
	# Derender previous moves and clear
	_render_moves(MOVE_get_to_cord(moves), true)
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
					valid_moves.append(Move.new(
						current.cord,
						left,
						false
					))
				elif i == 1 and _validate_potential_move(right):
					valid_moves.append(Move.new(
						current.cord,
						right,
						false
					))
				# no reason to continue executing since we know there isn't an oppenent piece
				continue 
			
			# NOTE: capturing checks
			if opponent_obsticals[i] != null:
				if i == 0:
					# left
					var capture_moves := _calculate_capture_moves(left, Vector2i(-1, -1))
					for move in capture_moves:
						valid_moves.append(move)
				elif i == 1:
					# right
					var capture_moves := _calculate_capture_moves(right, Vector2i(1, -1))
					for move in capture_moves:
						valid_moves.append(move)
				continue
	
	else:
		# King logic
		# basically the same except a bit more complicated
	
		# TODO: Impliment king logic here
		var king_moves = _valid_king_moves(piece_index)
		for kmove in king_moves:
			valid_moves.append(kmove)
	
	return valid_moves

func _calculate_capture_moves(cord: Vector2i, direction_vector: Vector2i) -> Array[Move]:
	var check_cord := Vector2i(cord + (direction_vector * turn_direction_multiplier))
	var op_blank_index = _search_opponent_pieces(check_cord)
	var pl_blank_index = _search_player_pieces(check_cord)
	var valid_moves : Array[Move]
	
	if pl_blank_index == null and op_blank_index == null and _validate_potential_move(check_cord):
		# Found a blank behind the cord
		var current_move = Move.new(
			cord - direction_vector,
			check_cord,
			true
		)
		current_move.set_captured_piece(cord)
		valid_moves.append(current_move)

	return valid_moves
	
func _capture_piece(move: Move):
	# clear the move hints
	_render_moves(MOVE_get_to_cord(moves), true)
	
	opponent_pieces.pop_at(_search_opponent_pieces(move.captured_piece))
	tile_map[2].erase_cell(move.captured_piece)
	
	moves.clear()

func _valid_king_moves(piece_index : int):
	var current := player_pieces[piece_index]
	var left := current.cord + Vector2i(-1, -1)
	var right := current.cord + Vector2i(1, -1)
	var left_back := current.cord + Vector2i(-1, 1)
	var right_back := current.cord + Vector2i(1, 1)
	var player_obsticals : Array
	var opponent_obsticals : Array
	var valid_moves : Array[Move]
	
	player_obsticals.append(_search_player_pieces(left))
	player_obsticals.append(_search_player_pieces(left_back))
	player_obsticals.append(_search_player_pieces(right))
	player_obsticals.append(_search_player_pieces(right_back))
	
	opponent_obsticals.append(_search_opponent_pieces(left))
	opponent_obsticals.append(_search_opponent_pieces(left_back))
	opponent_obsticals.append(_search_opponent_pieces(right))
	opponent_obsticals.append(_search_opponent_pieces(right_back))
	
	for i in range(len(player_obsticals)):
		'''
		Notes on order:
			*_obsticals = [left, left_back, right, right_back]
		'''
		if player_obsticals[i] == null and opponent_obsticals[i] == null:
			# uncomment and modify as needed for limited "Flying Kings"
			#var vector_moves = _check_king_direction_vector(left, Vector2i(-1, -1))
			if i == 0 and _validate_potential_move(left):
				valid_moves.append(Move.new(
					current.cord,
					left,
					false
				))
				
			if i == 1 and _validate_potential_move(left_back):
				valid_moves.append(Move.new(
					current.cord,
					left_back,
					false
				))
				
			if i == 2 and _validate_potential_move(right):
				valid_moves.append(Move.new(
					current.cord,
					right,
					false
				))
				
			if i == 3 and _validate_potential_move(right_back):
				valid_moves.append(Move.new(
					current.cord,
					right_back,
					false
				))
			
			continue
		
		if opponent_obsticals[i] != null: # if this index is not null, then player_obsticals' index must be null
			if i == 0:
				var capture_moves := _calculate_capture_moves(left, Vector2i(-1, -1) * turn_direction_multiplier)
				for move in capture_moves:
					valid_moves.append(move)
			if i == 1:
				var capture_moves := _calculate_capture_moves(left_back, Vector2i(-1, 1) * turn_direction_multiplier)
				for move in capture_moves:
					valid_moves.append(move)
			if i == 2:
				var capture_moves := _calculate_capture_moves(right, Vector2i(1, -1) * turn_direction_multiplier)
				for move in capture_moves:
					valid_moves.append(move)
			if i == 3:
				var capture_moves := _calculate_capture_moves(right_back, Vector2i(1, 1) * turn_direction_multiplier)
				for move in capture_moves:
					valid_moves.append(move)
		
	return valid_moves

func _check_king_direction_vector(start_tile: Vector2i, vector: Vector2i) -> Array[Move]:
	var check_tile := start_tile + (vector * turn_direction_multiplier)
	var player_obstical = _search_player_pieces(check_tile)
	var opponent_obstical = _search_opponent_pieces(check_tile)
	var valid_moves : Array[Move]
	
	if player_obstical == null and opponent_obstical == null and _validate_potential_move(check_tile):
		valid_moves.append(Move.new(
			start_tile,
			check_tile,
			false # this bool means that pure "Flying Kings" isn't possible
		))
		
		var recursive_moves = _check_king_direction_vector(check_tile, vector)
		for move in recursive_moves:
			valid_moves.append(move)
	
	return valid_moves

func _check_game_end() -> void:
	if len(black_pieces) == 0:
		UI.show()
		UI.get_child(0).get_child(0).get_child(1).show()
	
	if len(red_pieces) == 0:
		UI.show()
		UI.get_child(0).get_child(0).get_child(0).show()

func _move_piece(location: Vector2i) -> void:
	'''
	NOTE: Steps 2 - 3 are now handled by the Piece class
	keeping the function so I don't have to do any refactoring
	
	3 steps for moving a piece:
		1. De-highlight the current position
		2. Erase piece
		3. Draw new piece to the board 
		4. Update piece location
	'''
	
	# step 1
	player_pieces[current_piece_index].isSelected = false
	
	emit_signal("piece_moved")
	
	var king_row_check = _normalize_to_board_cord(location).y
	if not player_pieces[current_piece_index].get_isKing() and (king_row_check == 0 or king_row_check == 7):
		emit_signal("piece_crowned")
	
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

func _two_player_change_turns() -> void:
	if isPlayerRed: # red on the bottom of the board
		player_pieces = red_pieces
		opponent_pieces = black_pieces
	else:
		player_pieces = black_pieces
		opponent_pieces = red_pieces
	
	turn_direction_multiplier *= -1
	
	# god, this spagetti code is really getting messy
	
	# needs to be set to null since we are changing turns
	current_piece_index = null

func _renderer():
	# draw background
	var bgk_tile: Vector2i = Vector2i(0, 1)
	var square_red := Vector2i(0, 0)
	var square_white := Vector2i(1, 0)
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
				print_debug("Generating board cell (%d, %d)" % [x, y])
			
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
					
				else:
					red_pieces.append(Piece.new(
						true, 
						current_cord, 
						tile_map
					))
					
	
	if isDebugOn:
		print_debug("Placing debug op. piece")
		black_pieces.append(Piece.new(
			false,
			Vector2i(3 + board_origin.x, 4 + board_origin.y),
			tile_map
		))
	
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
				else:
					red_pieces.append(Piece.new(
						true, 
						current_cord, 
						tile_map
					))
	
func _render_moves(shadows: Array[Vector2i], erase: bool = false):
	var move_hint = Vector2i(1, 1)
	for s in shadows:
		if not erase:
			tile_map[3].set_cell(s, 0, move_hint)
		else:
			tile_map[3].erase_cell(s)
