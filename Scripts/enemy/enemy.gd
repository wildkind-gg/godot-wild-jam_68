extends Node2D

### Signals ###
signal on_action_started(action_message : String)
signal on_action_completed(action_message : String)
signal on_limb_hit(action_message : String)
signal on_run_away(action_message : String)
signal on_health_changed(current_health : float)
signal on_defeated(rewards : Array[RewardData])

### Constants ###
const MAX_PERCENT : float = 100.0
const TURN_STEP_DELAY : float = 0.75


### On Ready ###
@onready var _limb_gauges = {
	"Head" = $Enemy_Limbs/Enemy_Head,
	"Torso" = $Enemy_Limbs/Enemy_Torso,
	"RightArm" = $Enemy_Limbs/Enemy_Rarm,
	"LeftArm" = $Enemy_Limbs/Enemy_Larm,
	"RightLeg" = $Enemy_Limbs/Enemy_Rleg,
	"LeftLeg" = $Enemy_Limbs/Enemy_Lleg,
}


### Private Variables ###
var _current_limbs : Dictionary
var _current_rewards : Array[RewardData]
var _animation_player : AnimationPlayer

var _total_heal_actions: int
var _current_heal_actions: int
var _heal_amount : float

var _max_speed: float
var _current_speed: float

var _max_health : float
var _current_health : float
var _current_attack_damage : float


### References ###
var limb_object : PackedScene = preload("res://Scenes/components/limb.tscn")
var rng = RandomNumberGenerator.new()
var util : Util = Util.new()


### Private Methods ###
# Debug
func _debug_log_all_health() -> void:
	print("[Enemy] Limb Health:")
	for key in _current_limbs:
		var limb_health = _get_limb_health(key)
		print("- %s: %d" %[key, limb_health])


# Limb Creation
func _create_limb_object(parent : Node2D, limb_data : LimbData) -> Limb:
	var new_limb = limb_object.instantiate()
	new_limb.create(limb_data, parent.get_node("Shape"))

	parent.add_child(new_limb)
	return new_limb


func _generate_limbs(limb_points : Node2D, limbs : Array[LimbData]) -> void:
	# Add a limb for each data entry
	for i in limbs.size():
		var limb_data = limbs[i]
		var parent_name = _get_limb_name_by_type(limb_data.type)

		# Make sure we found a name for the limb
		if parent_name:
			var parent = limb_points.get_node(parent_name)
			var new_limb = _create_limb_object(parent, limb_data)
			new_limb.on_hit.connect(_on_limb_hit)
			new_limb.on_weak.connect(func(action_message : String):
				on_action_started.emit(action_message)
			)

			# Add to a dictionary
			_current_limbs[parent_name] = new_limb


func _generate_visuals(visuals_data : PackedScene) -> Node2D:
	# Remove old visuals
	var old_visuals = self.get_node("Visuals")
	if old_visuals:
		old_visuals.queue_free()

	# Instantiate new visuals
	var new_visuals = visuals_data.instantiate()
	_animation_player = new_visuals.get_node("AnimationPlayer")

	# Add complete attack method to signal
	_animation_player.animation_finished.connect(_complete_attack_action)

	self.add_child(new_visuals)
	return new_visuals.get_node("LimbPoints")


# Gauge helpers
func _process_gauges() -> void:
	for key in _limb_gauges:
		# Get data
		var ui_element = _limb_gauges[key]
		var value =  _get_limb_health_percent(key) * 100
		
		# Set ui value
		ui_element.value = value
		
		# Check to hide
		if value == MAX_PERCENT:
			ui_element.hide()
		else:
			ui_element.show()


# Data getters
func _get_limb_name_by_type(type : Global.LimbType) -> String:
	# May need to change this later, works for now
	var limb_point_names : Dictionary = {
		"Head" = Global.LimbType.HEAD,
		"Torso" = Global.LimbType.TORSO,
		"LeftArm" = Global.LimbType.LEFT_ARM,
		"RightArm" = Global.LimbType.RIGHT_ARM,
		"LeftLeg" = Global.LimbType.LEFT_LEG,
		"RightLeg" = Global.LimbType.RIGHT_LEG,
	}

	# Find the name that correlates to the type
	for key in limb_point_names:
		var value = limb_point_names[key]
		if value == type:
			return key

	# Error if there is no name for the type
	printerr("No limb point found for type %s" %type)
	return ""

func _get_limb_health(limb_name : String) -> float:
	return _current_limbs[limb_name].get_current_health()


func _get_limb_max_health(limb_name : String) -> float:
	return _current_limbs[limb_name].get_max_health()


func _get_limb_health_percent(limb_name : String) -> float:
	var max_health = _get_limb_max_health(limb_name)
	var health = _get_limb_health(limb_name)
	return health / max_health


func _get_total_limb_health_percent() -> float: ## Returns total limb health percentage
	var enemy_limb_health = _get_enemy_limb_health_percent_dict()
	var total_health = util.add_dictionary_values(enemy_limb_health)
	return total_health / enemy_limb_health.size()


func _get_total_limb_health() -> float: ## Returns total limb health percentage
	var enemy_limb_health = _get_enemy_limb_health_dict()
	var total_health = util.add_dictionary_values(enemy_limb_health)
	return total_health


func _get_enemy_limb_health_dict() -> Dictionary:
	# Enemy limb health pecentage dictionary
	var enemy_limb_health = {
		"Head": _get_limb_health("Head"), 
		"Torso": _get_limb_health("Torso"), 
		"LeftArm": _get_limb_health("LeftArm"), 
		"RightArm": _get_limb_health("RightArm"), 
		"LeftLeg": _get_limb_health("LeftLeg"), 
		"RightLeg": _get_limb_health("RightLeg"),
	}

	return enemy_limb_health


func _get_enemy_limb_health_percent_dict() -> Dictionary:
	# Enemy limb health pecentage dictionary
	var enemy_limb_health = {
		"Head": _get_limb_health_percent("Head"), 
		"Torso": _get_limb_health_percent("Torso"), 
		"LeftArm": _get_limb_health_percent("LeftArm"), 
		"RightArm": _get_limb_health_percent("RightArm"), 
		"LeftLeg": _get_limb_health_percent("LeftLeg"), 
		"RightLeg": _get_limb_health_percent("RightLeg"),
	}

	return enemy_limb_health


func _get_best_action(percents : Dictionary) -> String:
	return util.get_key_from_wieghted_dict(percents)


func _change_health(increment : float) -> void:
	_current_health += increment
	on_health_changed.emit(_current_health)

	if _current_health <= 0:
		destroy()


func _heal_limb(limb_name : String, amount : float) -> void:
	# Play an animation

	# Heal the limb
	_current_limbs[limb_name].heal_damage(amount)
	_change_health(amount)

	# Update visuals
	_process_gauges()

	# Broadcast action
	var heal_message = "Enemy heals its %s for %d health!" %[limb_name, amount]
	on_action_completed.emit(heal_message)


func _damage_calculation() -> float:
	# Add any bonus damage calculations here
	var base_damage = _current_attack_damage
	return base_damage


func _attack_player_part(part_name : String) -> void:
	# Play an animation

	# Have player take damage
	var damage = _damage_calculation()
	Global.current_player.take_damage(damage, part_name)
	
	# Broadcast action
	var action_message = "Enemy attacks %s" %part_name
	on_action_completed.emit(action_message)


# Signals
func _on_limb_hit(hit_message : String, damage_taken : float) -> void:
	# Play hit animation
	_animation_player.play("hit")

	# Remove health from damage done
	_change_health(-damage_taken)

	# Update visuals
	_process_gauges()

	if _is_alive():
		on_limb_hit.emit(hit_message)


# Actions
func _complete_attack_action(anim_name : String) -> void:
	var limb_weights = Global.current_player.get_flipped_limb_health_percent_dict()
	var best_limb = util.get_key_from_wieghted_dict(limb_weights)

	if anim_name == "tackle":
		_attack_player_part(best_limb)
			
		# end turn	
		end_enemy_turn()


func _take_attack_action() -> void:
	_animation_player.play("tackle")


func _take_heal_action() -> void:
	# choose best limb to heal from enemy_dict
	var enemy_limb_health = _get_enemy_limb_health_percent_dict()
	var best_limb = util.get_smallest_dict_value(enemy_limb_health)
	_heal_limb(best_limb, _heal_amount)

	# Reduce the amount of heal actions we can take
	_current_heal_actions -= 1

	# end turn	
	end_enemy_turn()


func _take_defend_action() -> void:
	# play an animation
	# enemy takes reduced or no damage on next turn
	var action_message = "Enemy defends!"
	on_action_completed.emit(action_message)
	
	# end turn	
	end_enemy_turn()


func _take_run_action() -> void:
	# play an animation
	# RNG to determine run chance, can't run if leg broken
	# if run is best action use RNG to determine if it is successful 
	# play animation and change scene

	# Run functions a little different since
	# we want to see attempt message before action is taken
	var action_message = "Enemy tries to run!"
	on_action_started.emit(action_message)

	# Wait a bit
	await get_tree().create_timer(TURN_STEP_DELAY).timeout

	# Get health pecentages
	var left_leg_health: float = _get_limb_health_percent("LeftLeg")
	var right_leg_health: float = _get_limb_health_percent("RightLeg")
	var leg_health = (left_leg_health + right_leg_health) / 2

	# Get any other run factors (in this case a flat 10% reduction to success)
	var other_factors = 0.1

	# Roll rng and increase our fail chance by other factors
	var chance_to_fail = rng.randf() + other_factors
	chance_to_fail = maxf(0.0, chance_to_fail)

	# We successfully run if our leg health is greater than our fail chance
	var was_successful = leg_health > chance_to_fail

	if was_successful:
		action_message = "Enemy runs away!"
		on_run_away.emit(action_message)
		return
	else:
		action_message = "Enemy fails to run away"
		on_action_completed.emit(action_message)

	# End turn
	end_enemy_turn()


# Action chance calculations
## Returns the risk to the enemy, higher is more threat
func _get_threat_level() -> float:
	# Get enemy and player total health percentages
	var enemy_health = _get_total_limb_health_percent()
	var player_health = Global.current_player.get_total_limb_health_percent()
	var normalized_difference = absf(enemy_health - player_health)

	# The threat level is generated from the
	# difference in health and how health the enemy is
	var threat_level = normalized_difference + (1 - enemy_health)
	return threat_level / 2


## How aggressive the enemy should be a high value here will encorage the enemy to attack
func _get_aggression_level() -> float:
	# Aggression reduces when threat is increased
	return 1 - _get_threat_level()


## How healthy the player is relative to the enemy, higher the stronger the player is
func _get_player_strength() -> float: 
	var enemy_health = _get_total_limb_health_percent()
	var player_health = Global.current_player.get_total_limb_health_percent()
	var player_strength = player_health / (player_health + enemy_health)
	return player_strength


func _get_attack_chance() -> float:
	# How aggressive the enemy should be
	var aggression_level = _get_aggression_level()

	# How healthy the player is relative to the enemy
	var player_strength = _get_player_strength()

	# The more aggressive we are and the weaker
	# the player is, the more likely we are to attack
	var attack_chance_percent = max(0, aggression_level * player_strength)
	return attack_chance_percent


func _get_heal_chance() -> float:
	# How aggressive the enemy should be
	var aggression_level = _get_aggression_level()
	
	# How healthy the player is relative to the enemy
	var player_strength = _get_player_strength()

	# The less aggressive we are and the stronger
	# the player is, the more likely we are to heal
	var starting_value = 1.0
	var heal_chance_percent = min(starting_value, starting_value + player_strength)
	heal_chance_percent -= aggression_level
	heal_chance_percent = max(0, heal_chance_percent)

	# Don't heal if we run out of heal actions
	if _current_heal_actions <= 0.0:
		heal_chance_percent = 0.0
	
	return heal_chance_percent


func _get_defend_chance() -> float:
	# How aggressive the enemy should be
	var aggression_level = _get_aggression_level()
	
	# How healthy the player is relative to the enemy
	var player_strength = _get_player_strength()

	# The less aggressive we are and the stronger
	# the player is, the more likely we are to defend
	var starting_value = 0.6
	var defend_chance_percent = min(starting_value, starting_value + player_strength)
	defend_chance_percent -= aggression_level
	defend_chance_percent = max(0, defend_chance_percent)

	# Defend note: add in 1 if a limb is below 30%?
	return defend_chance_percent


func _get_run_chance() -> float:
	# Run note: no chance to run if one or more legs are at 0%?
	# Run note: add 1 if a limb is below 20%?

	# Get leg health
	var left_leg_health: float = _get_limb_health_percent("LeftLeg")
	var right_leg_health: float = _get_limb_health_percent("RightLeg")
	
	# The higher the leg health, the more likely to run
	var leg_health_percent = (left_leg_health + right_leg_health) / 2

	# How aggressive the enemy is
	# The higher the aggression, the less likely to run 
	var aggression_level = _get_aggression_level() 

	# Run chance is a percentage of the remaining leg health
	var run_chance_percent = 1 - aggression_level

	# If we are over a threshold, check our leg health
	var run_threshold = 0.75
	if run_chance_percent > run_threshold:
		run_chance_percent = (run_chance_percent + leg_health_percent) / 2

	return run_chance_percent


func _is_alive() -> bool:
	return _current_health > 0


### Public Methods ###
func get_health_values() -> Dictionary:
	var health = {
		"current" = _current_health,
		"max" = _max_health,
	}
	return health


func create(new_enemy_data : EnemyData):
	# Set enemy stats
	_max_speed = new_enemy_data.max_speed
	_current_attack_damage = new_enemy_data.attack_damage
	_current_rewards = new_enemy_data.rewards

	# Heals
	_total_heal_actions = new_enemy_data.total_heal_actions
	_current_heal_actions = _total_heal_actions
	_heal_amount = new_enemy_data.heal_amount

	# Generate visuals and get limb points to add limbs to
	var limb_points = _generate_visuals(new_enemy_data.visuals)

	# Generate the enemy's limbs
	_generate_limbs(limb_points, new_enemy_data.limbs)

	# Setup health
	var max_health_pecent = new_enemy_data.max_health_percent / 100
	var total_limb_health = _get_total_limb_health()
	_max_health = total_limb_health * max_health_pecent
	_current_health = _max_health


func destroy() -> void:
	_current_health = 0
	on_health_changed.emit(_current_health)

	# Play death animation
	print("Enemy was defeated")

	# Signal that we were defeated (after animation if added)
	on_defeated.emit(_current_rewards)


func end_enemy_turn() -> void:
	# Wait for timer
	await get_tree().create_timer(TURN_STEP_DELAY).timeout	

	# Start enemy turn
	var next_turn = TurnManager.TurnType.PLAYER_TURN
	Global.current_turn_manager.change_turn(next_turn)


func take_enemy_turn() -> void:
	if not _is_alive():
		var next_turn = TurnManager.TurnType.NO_TURN
		Global.current_turn_manager.change_turn(next_turn)
		return

	# Wait for timer
	await get_tree().create_timer(TURN_STEP_DELAY).timeout	

	# DEBUG
	# _debug_log_all_health()
	
	# TODO: add something later calc is a place holder
	# choose best action from dictionary
	var action_weights = {
		"attack" : _get_attack_chance(),
		"heal": _get_heal_chance(),
		"defend": _get_defend_chance(),
		# "run": _get_run_chance(),
	}
	var best_action = _get_best_action(action_weights)
	print("Action: %s" %best_action)

	# Take chosen action
	if best_action == "attack":
		_take_attack_action()
	elif best_action == "heal":
		_take_heal_action()
	elif best_action == "defend":
		_take_defend_action()
	elif best_action == "run":
		_take_run_action()
	
	# if 2 calcs are equal, randomly choose any of them for easier difficulty
	# choose attack over defense action for harder difficulty
	# choose attack over defend and attack lowest health limb for harder difficulty
	# if debuffs/buffs added, choose buffs for hardest difficulty 

