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
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Head.value = Global.playerHead
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Rarm.value = Global.playerRarm
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Larm.value = Global.playerLarm
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Lleg.value = Global.playerLleg
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Rleg.value = Global.playerRleg
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Torso.value = Global.playerTorso
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Head.value = Global.enemyHead
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rarm.value = Global.enemyRarm
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Larm.value = Global.enemyLarm
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Lleg.value = Global.enemyLleg
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rleg.value = Global.enemyRleg
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Torso.value = Global.enemyTorso

func _on_player_turn_started():
	UI.show()
	
func _on_enemy_turn_started():
	Global.turnCounter += 1
	UI.hide()
	$Enemy._enemy_turn()
	# end turn
	$Label.text = "Enemy attacks your head!"
	await get_tree().create_timer(2).timeout #when animations added, on animation finished change turn and show ui
	turnmanager.turn = turnmanager.PLAYER_TURN

func _on_head_pressed():
	Global.enemyHead -= 25 #test value 
	$Label.text = "Enemies head attacked!"
	UI.hide()
	$AnimationPlayer.play("tackle")
	
func _on_torso_pressed():
	Global.enemyTorso -= 25 #test value 
	$Label.text = "Enemies torso attacked!"
	UI.hide()
	$AnimationPlayer.play("tackle")

func _on_left_arm_pressed():
	Global.enemyLarm -= 25 #test value 
	$Label.text = "Enemies left arm attacked!"
	UI.hide()
	$AnimationPlayer.play("tackle")

func _on_right_arm_pressed():
	Global.enemyRarm -= 25 #test value 
	$Label.text = "Enemy right arm attacked!"
	UI.hide()
	$AnimationPlayer.play("tackle")

func _on_left_leg_pressed():
	Global.enemyLleg -= 25 #test value 
	$Label.text = "Enemies left leg attacked!"
	UI.hide()
	$AnimationPlayer.play("tackle")

func _on_right_leg_pressed():
	Global.enemyRleg -= 25 #test value 
	$Label.text = "Enemies right leg attacked!"
	UI.hide()
	$AnimationPlayer.play("tackle")

func _on_defend_pressed():
	pass # Replace with function body.


func _on_run_pressed():
	pass # Replace with function body.


func _on_animation_player_animation_finished(_anim_name):
	await get_tree().create_timer(1).timeout
	turnmanager.turn = turnmanager.ENEMY_TURN
