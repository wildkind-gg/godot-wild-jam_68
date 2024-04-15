# Creates a transtion between two scenes
class_name SceneTransition
extends Node2D

### Editor Parameters ###
@export var landing_scene : PackedScene
@export var fade_transition : ColorRect

### Private Variables ###
var _is_running_transition : bool = false

### Public Functions ###
func start_transition() -> void:
	# Validate landing scene
	if landing_scene == null:
		printerr("[start_transition] No landing scene set for the scene transition")
	elif _is_running_transition:
		print("[start_transition] Transition in progress")
		return
	
	# Flag that the transition started
	_is_running_transition = true
	
	# Run any transition animations
	if fade_transition != null:
		fade_transition.play_fade_out()
		fade_transition.on_animation_completed.connect(complete_transition)
	else:
		complete_transition()


func complete_transition() -> void:
	# Change scene
	var results = get_tree().change_scene_to_packed(landing_scene)
	
	# Validate that the scene transitioned
	if results != OK:
		printerr("[complete_transition] Was unable to change scene to '%s'" %landing_scene)
	
	# Flag that the transition is completed
	_is_running_transition = false

