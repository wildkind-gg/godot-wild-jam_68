extends Node2D

func _process(_delta):
	pass

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/battle.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_options_pressed():
	pass # Replace with function body.


func _on_controls_pressed():
	$Container/ControlsText.show()


func _on_button_pressed():
	$Container/ControlsText.hide()
