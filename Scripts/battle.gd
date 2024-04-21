extends Node2D


### On Ready Varaibles ###
@onready var player = $Player
@onready var enemy = $Enemy

# Scene Transition
@onready var fade_transition = $Transition/FadeTransition
@onready var forge_scene_transition = $Transition/ForgeSceneTransition

# UI
@onready var player_action_ui = $UI/Battle_UI
@onready var rewards_popup = $UI/Rewards
@onready var rewards_popup_animator = $UI/Rewards/RewardsAnimator
@onready var rewards_container = $UI/Rewards/MarginContainer/RewardsContainer
@onready var reward_item = preload("res://Scenes/components/reward_button.tscn")
@onready var message_container = $UI/BattleMessages/MarginContainer/MessageContainer
@onready var action_message_item = preload("res://Scenes/components/action_message.tscn")

# Enemy UI Info
@onready var enemy_health_bar = $UI/EnemyInfo/MarginContainer/Stack/Health/EnemyHealth
@onready var enemy_health_bar_value = $UI/EnemyInfo/MarginContainer/Stack/Health/EnemyHealth/ValueLabel
@onready var enemy_defend_icon = $UI/EnemyInfo/MarginContainer/Stack/Health/DefendIcon
@onready var enemy_crit_bar = $UI/EnemyInfo/MarginContainer/Stack/CritBar/EnemyCrit
@onready var enemy_crit_bar_value = $UI/EnemyInfo/MarginContainer/Stack/CritBar/EnemyCrit/ValueLabel
@onready var enemy_name = $UI/EnemyInfo/MarginContainer/Stack/NameLabel


### EXPORTS ###
@export var debug_enemy : EnemyData


### Public Variables ###
var rnd = RandomNumberGenerator.new()
var turn_type = TurnManager.TurnType


### Public Methods ###
func move_to_forge() -> void:
	forge_scene_transition.start_transition()


func move_to_menu() -> void:
	fade_transition.play_fade_out()
	fade_transition.on_animation_completed.connect(func():
		get_tree().change_scene_to_file("res://Scenes/menus/main_menu.tscn")
	)


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
	# Use the debug enemy if we didn't recieve an enemy
	if not new_enemy_data:
		new_enemy_data = debug_enemy
	
	# Create the enemy
	enemy.create(new_enemy_data)

	# Connect enemy signals
	enemy.on_defeated.connect(on_player_win)
	enemy.on_action_completed.connect(_broadcast_action)
	enemy.on_action_started.connect(_broadcast_action)
	enemy.on_health_changed.connect(_on_enemy_health_update)
	enemy.on_defend.connect(_update_defend_buff)
	enemy.on_crit_changed.connect(_on_enemy_crit_update)
	enemy.on_limb_hit.connect(_on_enemy_limb_hit)
	enemy.on_run_away.connect(_on_run_success)

	# Enemy UI Info
	# Update health bar
	var health_values = enemy.get_health_values()
	enemy_health_bar.max_value = health_values.max
	_on_enemy_health_update(health_values.current, health_values.max)
	_update_defend_buff(false) # Hide defend at start
	_on_enemy_crit_update(0, new_enemy_data.crit_amount)

	# Update name
	enemy_name.text = new_enemy_data.display_name


func on_player_win(rewards) -> void:
	if rewards.size() > 0:
		generate_rewards(rewards)
	else:
		move_to_forge()
		

func on_player_lose(death_message : String) -> void:
	# Don't allow player to act
	var next_turn = turn_type.NO_TURN
	Global.current_turn_manager.change_turn(next_turn)

	_broadcast_action(death_message)
	
	# Wait for death animations
	await get_tree().create_timer(6).timeout
	
	# Move back to menu
	move_to_menu()


func on_scene_loaded() -> void:
	# Make sure to hide popup
	rewards_popup.hide()

	# Fade in animation
	fade_transition.play_fade_in()

	# Create turn manager
	Global.current_turn_manager = TurnManager.new()

	# Connect to turns
	Global.current_turn_manager.player_turn_started.connect(_on_player_turn_started)
	Global.current_turn_manager.enemy_turn_started.connect(_on_enemy_turn_started)

	# Setup player
	player.create()
	Global.current_player = player
	player.on_death.connect(on_player_lose)
	player.broadcast_message.connect(_broadcast_action)

	# Setup enemy
	var new_enemy_data = Global.current_enemy_data
	generate_enemy(new_enemy_data)
	Global.current_enemy = enemy

	# Set as player's turn to start
	var next_turn = turn_type.PLAYER_TURN
	Global.current_turn_manager.change_turn(next_turn)


### Private Methods ###
func _generate_reward(reward : RewardData) -> Button:
	var new_reward = reward_item.instantiate()
	var abbreviation = Global.stat_display_data[reward.stat].abbreviation
	var reward_text = "Gain %s: +%d %s" %[reward.display_name, reward.increase, abbreviation]
	new_reward.text = reward_text
	return new_reward


func _create_new_action_message(action_message : String) -> Label:
	var new_message = action_message_item.instantiate()
	new_message.text = action_message
	return new_message


func _broadcast_action(action_message : String) -> void:
	var new_message = _create_new_action_message(action_message)
	message_container.add_child(new_message)


func _on_player_action(delay : float = 1) -> void:
	# Hide the players available actions
	player_action_ui.hide()

	# Set turn as inbetween since we want to see player action
	var next_turn = TurnManager.TurnType.NO_TURN
	Global.current_turn_manager.change_turn(next_turn)
	
	# Wait for a second
	await get_tree().create_timer(delay).timeout

	# Unlock after delay and move to enemy turn
	next_turn = TurnManager.TurnType.ENEMY_TURN
	Global.current_turn_manager.change_turn(next_turn)


func _on_enemy_limb_hit(hit_message : String) -> void:
	_broadcast_action(hit_message)
	
	# Say we took our action
	_on_player_action()


func _on_run_success(action_text) -> void:
	_broadcast_action(action_text)

	# Wait a second to see the messages
	await get_tree().create_timer(1.5).timeout

	# Return to bounty board
	get_tree().change_scene_to_file("res://Scenes/bounty_board/bounty_board.tscn")


func _on_run_fail() -> void:
	var action_text = "Could not get away!"
	_broadcast_action(action_text)
	
	# Say we took our action
	var action_delay = 1.5
	_on_player_action(action_delay)


func _on_enemy_health_update(current_health : float, max_health : float) -> void:
	enemy_health_bar.value = current_health
	enemy_health_bar_value.text = "%d/%d" %[current_health, max_health]


func _update_defend_buff(flag : bool) -> void:
	enemy_defend_icon.visible = flag


func _on_enemy_crit_update(current_crit : float, amount_needed : float) -> void:
	enemy_crit_bar.value = current_crit
	enemy_crit_bar_value.text = "%d/%d" %[current_crit, amount_needed]

	if current_crit >= amount_needed:
		enemy_crit_bar.self_modulate = Color(1, 0, 0)
	else:
		enemy_crit_bar.self_modulate = Color(1, 1, 0)


### Built in Methods ###
func _ready() -> void:
	MenuMusic.volume_db = -80
	ForgeMusic.volume_db = -80
	BattleMusic.volume_db = 0
	on_scene_loaded()

	
func _process(_delta):
	# leave game press esc
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://Scenes/menus/main_menu.tscn")


### Signals Connected ###
func _on_player_turn_started():
	var turn_start_message = "Your turn"
	_broadcast_action(turn_start_message)

	player_action_ui.show()


func _on_enemy_turn_started():
	var turn_start_message = "Enemy's turn"
	_broadcast_action(turn_start_message)
	
	Global.turnCounter += 1
	enemy.take_enemy_turn()


func _on_defend_pressed():
	Global.current_player.take_defend_action()

	# Say we took our action
	_on_player_action()


func _on_run_pressed():
	# TODO: Move this to a player script
	var rng = rnd.randi_range(0,10)
	var right_leg = Global.current_player.get_limb_health_percent("Right Leg")
	var left_leg = Global.current_player.get_limb_health_percent("Left Leg")
	if left_leg <= 0 or right_leg <= 0:
		rng = 0
		
		var action_text = "Your leg is broken!"
		_broadcast_action(action_text)
	else:
		if rng >= 3:
			var action_text = "You run away!"
			_on_run_success(action_text)
		if rng < 3:
			_on_run_fail()
