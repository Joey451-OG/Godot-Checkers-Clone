extends Control


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file(Globals.scene_dict["game"])

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(Globals.scene_dict["main_menu"])

func _on_exit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
