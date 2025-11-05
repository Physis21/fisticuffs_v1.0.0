extends Control


func _on_resume_button_pressed() -> void:
	owner.play_pause_menu()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
