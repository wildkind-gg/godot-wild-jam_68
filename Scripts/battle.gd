extends Node2D

### Exports ###
@export var enemy_data : EnemyData


### On Ready Varaibles ###
@onready var player = $Player
@onready var enemy = $Enemy
@onready var UI = $UI/Battle_UI


### Public Variables ###
var rnd = RandomNumberGenerator.new()
var current_turn_manager : TurnManager
var turn_type = TurnManager.TurnType


### Public Methods ###
func generate_enemy(new_enemy_data : EnemyData) -> void:
	enemy.create(new_enemy_data)
	enemy.on_limb_hit.connect(_on_enemy_limb_hit)
	enemy.on_action_completed.connect(_broadcast_action)


### Private Methods ###
func _broadcast_action(action_message : String) -> void:
	$Label.text = action_message


func _on_player_action(delay : float) -> void:
	# Set turn as inbetween since we want to see player action
	var next_turn = TurnManager.TurnType.NO_TURN
	current_turn_manager.change_turn(next_turn)
	
	# Lock turn change so player can't take two in a row
	current_turn_manager.lock_turn_change()
	await get_tree().create_timer(delay).timeout

	# Unlock after delay and move to enemy turn
	current_turn_manager.unlock_turn_change()
	next_turn = TurnManager.TurnType.ENEMY_TURN
	current_turn_manager.change_turn(next_turn)


func _on_enemy_limb_hit(hit_message : String) -> void:
	_broadcast_action(hit_message)
	
	# TODO: This should be called from the player
	# and the animation should be on player
	$AnimationPlayer.play("tackle")

	# Say we took our action
	var action_delay = 1
	_on_player_action(action_delay)


func _on_run_success() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_run_fail() -> void:
	var action_text = "Could not get away!"
	_broadcast_action(action_text)
	
	# Say we took our action
	var action_delay = 1
	_on_player_action(action_delay)


### Built in Methods ###
func _ready() -> void:
	# Create turn manager
	current_turn_manager = TurnManager.new()

	# Create enemy
	generate_enemy(enemy_data)

	# connect to turns
	current_turn_manager.player_turn_started.connect(self._on_player_turn_started)
	current_turn_manager.enemy_turn_started.connect(self._on_enemy_turn_started)

	
func _process(_delta):
	# leave game press esc
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	### enemy gauges ###
	# $UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Head.value = Global.enemyHead
	# if Global.enemyHead == 100 or Global.enemyHead == 0:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Head.hide()
	# else:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Head.show()
	# if Global.enemyHead == 0:
	# 	$UI/Battle_UI/Head.disabled = true
		
	# $UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rarm.value = Global.enemyRarm
	# if Global.enemyRarm == 100 or Global.enemyRarm == 0:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rarm.hide()
	# else:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rarm.show()
	# if Global.enemyRarm == 0:
	# 	$UI/Battle_UI/Right_Arm.disabled = true
		
	# $UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Larm.value = Global.enemyLarm
	# if Global.enemyLarm == 100  or Global.enemyLarm == 0:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Larm.hide()
	# else:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Larm.show()
	# if Global.enemyLarm == 0:
	# 	$UI/Battle_UI/Left_Arm.disabled = true
		
	# $UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Lleg.value = Global.enemyLleg
	# if Global.enemyLleg == 100 or Global.enemyLleg == 0:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Lleg.hide()
	# else:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Lleg.show()
	# if Global.enemyLleg == 0:
	# 	$UI/Battle_UI/Left_Leg.disabled = true
		
	# $UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rleg.value = Global.enemyRleg
	# if Global.enemyRleg == 100 or Global.enemyRleg == 0:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rleg.hide()
	# else:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Rleg.show()
	# if Global.enemyRleg == 0:
	# 	$UI/Battle_UI/Right_Leg.disabled = true
		
	# $UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Torso.value = Global.enemyTorso
	# if Global.enemyTorso == 100 or Global.enemyTorso == 0:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Torso.hide()
	# else:
	# 	$UI/Battle_UI/Gauges/Enemy_Limbs/Enemy_Torso.show()
	# if Global.enemyTorso == 0:
	# 	$UI/Battle_UI/Torso.disabled = true


### Signals Connected ###
func _on_player_turn_started():
	UI.show()


func _on_enemy_turn_started():
	Global.turnCounter += 1
	UI.hide()
	enemy.take_enemy_turn(current_turn_manager)


func _on_defend_pressed():
	# TODO: Move this to a player script
	# Replace with function body.

	# Say we took our action
	var action_delay = 1
	_on_player_action(action_delay)


func _on_run_pressed():
	# TODO: Move this to a player script
	var rng = rnd.randi_range(0,10)
	if Global.playerLleg <= 0 or Global.playerRleg <= 0:
		rng = 0
		
		var action_text = "Your leg is broken!"
		_broadcast_action(action_text)
	else:
		if rng >= 3:
			_on_run_success()
		if rng < 3:
			_on_run_fail()

