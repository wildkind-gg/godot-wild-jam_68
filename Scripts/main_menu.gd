extends Node2D

### On Ready Varaibles ###
@onready var scene_transition := $Container/VBoxContainer/Play/SceneTransition

### Private Methods ###
func _process(_delta):
	pass


### Signal Connected Methods ###
func _on_play_pressed():
	scene_transition.start_transition()

func _on_exit_pressed():
	get_tree().quit()

func _on_options_pressed():
	pass # Replace with function body.


func _on_controls_pressed():
	$Container/ControlsText.show()


func _on_button_pressed():
	$Container/ControlsText.hide()
