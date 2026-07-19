extends Control
@export var game : PackedScene

func _on_play_pressed() -> void:
	# load game.tscn
	get_tree().change_scene_to_packed(game)

func _on_check_button_toggled(toggled_on: bool) -> void:
	Globals.isPlayerOneRed = not toggled_on
	
