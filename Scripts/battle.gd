extends Node2D


### On Ready Varaibles ###
@onready var player = $Player
@onready var enemy = $Enemy
@onready var UI = $UI/Battle_UI
@onready var scene_transition = $Transition/SceneTranstion
@onready var fade_transition = $Transition/SceneTransition/FadeTransition


### Public Variables ###
var rnd = RandomNumberGenerator.new()
var current_turn_manager : TurnManager
var turn_type = TurnManager.TurnType


### Public Methods ###
func generate_enemy(new_enemy_data : EnemyData) -> void:
	enemy.create(new_enemy_data)
	enemy.on_limb_hit.connect(_on_enemy_limb_hit)
	enemy.on_action_completed.connect(_broadcast_action)


func on_player_win() -> void:
	scene_transition.start_transition()


func on_scene_loaded() -> void:
	# Fade in animation
	fade_transition.play_fade_in()

	# Create turn manager
	current_turn_manager = TurnManager.new()

	# Connect to turns
	current_turn_manager.player_turn_started.connect(self._on_player_turn_started)
	current_turn_manager.enemy_turn_started.connect(self._on_enemy_turn_started)

	# Setup player
	player.create(current_turn_manager)
	Global.current_player = player

	# Setup enemy
	var new_enemy_data = Global.current_enemy
	generate_enemy(new_enemy_data)

	# Set as player's turn to start
	var next_turn = turn_type.PLAYER_TURN
	current_turn_manager.change_turn(next_turn)


### Private Methods ###
func _broadcast_action(action_message : String) -> void:
	$Label.text = action_message


func _on_player_action(delay : float) -> void:
	# Set turn as inbetween since we want to see player action
	var next_turn = TurnManager.TurnType.NO_TURN
	current_turn_manager.change_turn(next_turn)
	
	# Wait for a second
	await get_tree().create_timer(delay).timeout

	# Unlock after delay and move to enemy turn
	next_turn = TurnManager.TurnType.ENEMY_TURN
	current_turn_manager.change_turn(next_turn)


func _on_enemy_limb_hit(hit_message : String) -> void:
	_broadcast_action(hit_message)
	
	# TODO: This should be called from the player
	# and the animation should be on player scene
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
	on_scene_loaded()

	
func _process(_delta):
	# leave game press esc
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


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

