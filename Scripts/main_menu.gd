extends Node2D

### On Ready Varaibles ###
@onready var landing_scene = preload("res://Scenes/bounty_board/bounty_board.tscn")
@onready var scene_transition := $Container/VBoxContainer/Play/SceneTransition


### Signal Connected Methods ###
func _on_play_pressed():
	scene_transition.landing_scene = landing_scene
	scene_transition.start_transition()

func _on_exit_pressed():
	get_tree().quit()

func _on_options_pressed():
	pass # Replace with function body.


func _on_controls_pressed():
	$Container/ControlsText.show()


func _on_button_pressed():
	$Container/ControlsText.hide()
