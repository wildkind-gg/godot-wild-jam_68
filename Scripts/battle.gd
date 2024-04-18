extends Node2D


### On Ready Varaibles ###
@onready var player = $Player
@onready var enemy = $Enemy

# Scene Transition
@onready var fade_transition = $Transition/FadeTransition
@onready var forge_scene_transition = $Transition/ForgeSceneTransition
@onready var menu_scene_transition = $Transition/MenuSceneTransition

# UI
@onready var UI = $UI/Battle_UI
@onready var rewards_popup = $UI/Rewards
@onready var rewards_popup_animator = $UI/Rewards/RewardsAnimator
@onready var rewards_container = $UI/Rewards/MarginContainer/RewardsContainer
@onready var reward_item = preload("res://Scenes/components/reward_button.tscn")

# Enemy UI Info
@onready var enemy_health_bar = $UI/EnemyInfo/MarginContainer/Stack/Health/EnemyHealth
@onready var enemy_health_bar_value = $UI/EnemyInfo/MarginContainer/Stack/Health/EnemyHealth/ValueLabel
@onready var enemy_name = $UI/EnemyInfo/MarginContainer/Stack/NameLabel


### Public Variables ###
var rnd = RandomNumberGenerator.new()
var current_turn_manager : TurnManager
var turn_type = TurnManager.TurnType


### Public Methods ###
func move_to_forge() -> void:
	forge_scene_transition.start_transition()


func move_to_menu() -> void:
	menu_scene_transition.start_transition()


func generate_rewards(rewards : Array[RewardData]) -> void:
	# Show popup
	rewards_popup.show()
	rewards_popup_animator.play("popup")

	# Remove any old rewards
	for child in rewards_container.get_children():
		if child is Button:
			child.queue_free()

	# Create rewards
	for reward in rewards:
		var new_reward = _generate_reward(reward)
		new_reward.pressed.connect(move_to_forge)
		rewards_container.add_child(new_reward)

	
func generate_enemy(new_enemy_data : EnemyData) -> void:
	# Create the enemy
	enemy.create(new_enemy_data)

	# Connect enemy signals
	enemy.on_defeated.connect(on_player_win)
	enemy.on_action_completed.connect(_broadcast_action)
	enemy.on_health_changed.connect(_on_enemy_health_update)
	enemy.on_limb_hit.connect(_on_enemy_limb_hit)

	# Enemy UI Info
	# Update health bar
	var health_values = enemy.get_health_values()
	enemy_health_bar.max_value = health_values.max
	_on_enemy_health_update(health_values.current)

	# Update name
	enemy_name.text = new_enemy_data.display_name


func on_player_win(rewards) -> void:
	if rewards.size() > 0:
		generate_rewards(rewards)
	else:
		move_to_forge()
		

func on_player_lose(death_message : String) -> void:
	_broadcast_action(death_message)
	
	# Wait for death animations
	await get_tree().create_timer(1).timeout
	
	# Move back to menu
	move_to_menu()


func on_scene_loaded() -> void:
	# Make sure to hide popup
	rewards_popup.hide()

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
	player.on_death.connect(on_player_lose)

	# Setup enemy
	var new_enemy_data = Global.current_enemy
	generate_enemy(new_enemy_data)

	# Set as player's turn to start
	var next_turn = turn_type.PLAYER_TURN
	current_turn_manager.change_turn(next_turn)


### Private Methods ###
func _generate_reward(reward : RewardData) -> Button:
	var new_reward = reward_item.instantiate()
	var reward_text = "Gain %s: +%d %s" %[reward.display_name, reward.increase, reward.display_stat]
	new_reward.text = reward_text
	return new_reward


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


func _on_enemy_health_update(current_health : float) -> void:
	enemy_health_bar.value = current_health
	enemy_health_bar_value.text = "%d" %current_health


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

