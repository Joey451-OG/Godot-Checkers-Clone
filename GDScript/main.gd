extends Node2D

# renderer var	
@export var tile_map: Array[TileMapLayer]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_renderer()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _renderer():
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
			print_debug("(%d, %d)" % [x, y])
			if (x + y) % 2 == 0:
				tile_map[1].set_cell(Vector2i(x, y), 0, square_white)
			else:
				tile_map[1].set_cell(Vector2i(x, y), 0, square_red)

	# border
	
	tile_map[1].set_cell(Vector2i(4, 1), 0, board_border)
	
	
	
