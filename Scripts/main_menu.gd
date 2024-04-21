extends Node2D

### On Ready Varaibles ###
@onready var landing_scene = preload("res://Scenes/intro.tscn")
@onready var scene_transition := $Container/VBoxContainer/Play/SceneTransition

func _ready():
	IntroSound.play()
	MenuMusic.play()
	ForgeMusic.play()
	ForgeMusic.volume_db = -80
	BattleMusic.play()
	BattleMusic.volume_db = -80
	await get_tree().create_timer(2).timeout
	MenuMusic.volume_db = 0.0
	

### Signal Connected Methods ###
func _on_play_pressed():
	scene_transition.landing_scene = landing_scene
	scene_transition.start_transition()
	
func _on_exit_pressed():
	get_tree().quit()

func _on_controls_pressed():
	$Container/ControlsText.show()

func _on_button_pressed():
	$Container/ControlsText.hide()
