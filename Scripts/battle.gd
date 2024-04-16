extends Node
	
var turnmanager = preload("res://Resources/TurnManager.tres")
@onready var player = preload("res://Scenes/battles_enemies/player.tscn")
@onready var UI = $UI/Battle_UI
var rndm = RandomNumberGenerator.new()
@onready var current_enemy = $Grognor.name
	
func _ready():
	# connect to turns
	turnmanager.player_turn_started.connect(self._on_player_turn_started)
	turnmanager.enemy_turn_started.connect(self._on_enemy_turn_started)
	
	
func _process(_delta):
	# leave game press esc
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

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
	$Grognor._enemy_turn()
	# end turn
	$Label.text = Global.enemyAction
	await get_tree().create_timer(2).timeout #when animations added, on animation finished change turn and show ui
	turnmanager.turn = turnmanager.PLAYER_TURN

func _on_head_pressed():
	Global.enemyHead -= 25 #test value 
	$Label.text = "You attack %s's head!" %current_enemy
	UI.hide()
	$AnimationPlayer.play("tackle")
	
func _on_torso_pressed():
	Global.enemyTorso -= 25 #test value 
	$Label.text = "You attack %s's torso!" %current_enemy
	UI.hide()
	$AnimationPlayer.play("tackle")

func _on_left_arm_pressed():
	Global.enemyLarm -= 25 #test value 
	$Label.text = "You attack %s's left arm!" %current_enemy
	UI.hide()
	$AnimationPlayer.play("tackle")

func _on_right_arm_pressed():
	Global.enemyRarm -= 25 #test value 
	$Label.text = "You attack %s's right arm!" %current_enemy
	UI.hide()
	$AnimationPlayer.play("tackle")

func _on_left_leg_pressed():
	Global.enemyLleg -= 25 #test value 
	$Label.text = "You attack %s's left leg!" %current_enemy
	UI.hide()
	$AnimationPlayer.play("tackle")

func _on_right_leg_pressed():
	Global.enemyRleg -= 25 #test value 
	$Label.text = "You attack %s's right leg!" %current_enemy
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
	print(Global.playerHead)
	turnmanager.turn = turnmanager.ENEMY_TURN
