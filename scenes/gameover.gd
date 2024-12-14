extends CanvasLayer

func on_play_again_pressed():
	# Unpause the game
	get_tree().paused = false

	# Change to the main game scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()
