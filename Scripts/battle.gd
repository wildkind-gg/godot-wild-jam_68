extends Node2D
	
var turnmanager = preload("res://Resources/TurnManager.tres")
@onready var player = $Player
@onready var UI = $UI/Battle_UI
var rndm = RandomNumberGenerator.new()
	
func _ready():
	# connect to turns
	turnmanager.player_turn_started.connect(self._on_player_turn_started)
	turnmanager.enemy_turn_started.connect(self._on_enemy_turn_started)
	
	
func _process(_delta):
	print(Global.playerHead)
	# leave game press esc
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
### player gauges ###
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Head.value = Global.playerHead
	if Global.playerHead == 100:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Head.hide()
	else:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Head.show()
		
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Rarm.value = Global.playerRarm
	if Global.playerRarm == 100:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Rarm.hide()
	else:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Rarm.show()

	$UI/Battle_UI/Gauges/Player_Limbs/Player_Larm.value = Global.playerLarm
	if Global.playerLarm == 100:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Larm.hide()
	else:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Larm.show()
		
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Lleg.value = Global.playerLleg
	if Global.playerLleg == 100:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Lleg.hide()
	else:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Lleg.show()
		
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Rleg.value = Global.playerRleg
	if Global.playerRleg == 100:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Rleg.hide()
	else:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Rleg.show()
		
	$UI/Battle_UI/Gauges/Player_Limbs/Player_Torso.value = Global.playerTorso
	if Global.playerTorso == 100:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Torso.hide()
	else:
		$UI/Battle_UI/Gauges/Player_Limbs/Player_Torso.show()

### enemy gauges ###
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Head.value = Global.enemyHead
	if Global.enemyHead == 100 or Global.enemyHead == 0:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Head.hide()
	else:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Head.show()
	if Global.enemyHead == 0:
		$UI/Battle_UI/Head.disabled = true
		
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rarm.value = Global.enemyRarm
	if Global.enemyRarm == 100 or Global.enemyRarm == 0:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rarm.hide()
	else:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rarm.show()
	if Global.enemyRarm == 0:
		$UI/Battle_UI/Right_Arm.disabled = true
		
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Larm.value = Global.enemyLarm
	if Global.enemyLarm == 100  or Global.enemyLarm == 0:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Larm.hide()
	else:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Larm.show()
	if Global.enemyLarm == 0:
		$UI/Battle_UI/Left_Arm.disabled = true
		
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Lleg.value = Global.enemyLleg
	if Global.enemyLleg == 100 or Global.enemyLleg == 0:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Lleg.hide()
	else:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Lleg.show()
	if Global.enemyLleg == 0:
		$UI/Battle_UI/Left_Leg.disabled = true
		
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rleg.value = Global.enemyRleg
	if Global.enemyRleg == 100 or Global.enemyRleg == 0:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rleg.hide()
	else:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rleg.show()
	if Global.enemyRleg == 0:
		$UI/Battle_UI/Right_Leg.disabled = true
		
	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Torso.value = Global.enemyTorso
	if Global.enemyTorso == 100 or Global.enemyTorso == 0:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Torso.hide()
	else:
		$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Torso.show()
	if Global.enemyTorso == 0:
		$UI/Battle_UI/Torso.disabled = true
		
func _on_player_turn_started():
	UI.show()
	
func _on_enemy_turn_started():
	Global.turnCounter += 1
	UI.hide()
	$Enemy._enemy_turn()
	# end turn
	$Label.text = Global.enemyAction
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
	var rng = rndm.randi_range(0,10)
	if Global.playerLleg <= 0 or Global.playerRleg <= 0:
		rng = 0
		$Label.text = "Your leg is broken!"
	else:
		if rng >= 3:
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		if rng < 3:
			$Label.text = "Could not get away!"
			await get_tree().create_timer(2).timeout
			turnmanager.turn = turnmanager.ENEMY_TURN
		
func _on_animation_player_animation_finished(_anim_name):
	await get_tree().create_timer(1).timeout
	turnmanager.turn = turnmanager.ENEMY_TURN
