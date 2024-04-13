extends Node2D
	
var turnmanager = preload("res://Resources/TurnManager.tres")
@onready var player = $Player
@onready var UI = $UI/Battle_UI
	
func _ready():
	# connect to turns
	turnmanager.player_turn_started.connect(self._on_player_turn_started)
	turnmanager.enemy_turn_started.connect(self._on_enemy_turn_started)
	
	
func _process(_delta):
	# leave game press esc
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	$UI/Battle_UI/Gauges/Player_Head.value = Global.playerHead
	$UI/Battle_UI/Gauges/Enemy_Head.value = Global.enemyHead
	if Global.enemyHead <= 0:
		get_tree().quit()
	

func _on_player_turn_started():
	UI.show()
	
func _on_enemy_turn_started():
	UI.hide()
	$Label.text = "Enemy attacks your head!"
	await get_tree().create_timer(2).timeout #when animations added, on animation finished change turn and show ui
	turnmanager.turn = turnmanager.PLAYER_TURN

func _on_head_pressed():
	Global.enemyHead -= 25 #test value 
	$Label.text = "Enemy head attacked!"
	UI.hide()
	$AnimationPlayer.play("tackle")
	


func _on_torso_pressed():
	pass # Replace with function body.


func _on_left_arm_pressed():
	pass # Replace with function body.


func _on_right_arm_pressed():
	pass # Replace with function body.


func _on_left_leg_pressed():
	pass # Replace with function body.


func _on_right_leg_pressed():
	pass # Replace with function body.


func _on_defend_pressed():
	pass # Replace with function body.


func _on_run_pressed():
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name):
	await get_tree().create_timer(1).timeout
	turnmanager.turn = turnmanager.ENEMY_TURN
