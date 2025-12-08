extends Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('pause'):
		play_pause_menu()
		
func play_pause_menu():
	owner.paused = !owner.paused
	if not owner.paused:
		get_tree().paused = false
		self.hide()
		Engine.time_scale = 1
		#PhysicsServer2D.set_active(true)
	else:
		get_tree().paused = true
		self.show()
		Engine.time_scale = 0
		#PhysicsServer2D.set_active(false)
		
func _on_resume_button_pressed() -> void:
	#owner.play_pause_menu()
	play_pause_menu()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
