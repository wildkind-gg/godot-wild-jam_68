extends Node2D

func _ready():
	$AnimationPlayer.play("fade in")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade in":
		await get_tree().create_timer(2).timeout
		$AnimationPlayer.play("fade in button")
	if anim_name == "fade out":
		get_tree().change_scene_to_file("res://Scenes/menus/main_menu.tscn")
		

func _on_button_pressed():
	$AnimationPlayer.play("fade out")
