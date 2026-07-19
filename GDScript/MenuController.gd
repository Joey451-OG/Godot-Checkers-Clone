extends Control

func _on_play_pressed() -> void:
	# load game.tscn
	get_tree().change_scene_to_file(Globals.scene_dict["game"])

func _on_check_button_toggled(toggled_on: bool) -> void:
	Globals.isPlayerOneRed = not toggled_on
	
