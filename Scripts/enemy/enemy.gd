extends Node2D

### Signals ###
signal on_action_completed(action_message : String)
signal on_limb_hit(hit_message : String)


### Constants ###
const MAX_PERCENT : float = 100.0


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
var _max_speed: float
var _current_speed: float
var _total_heals: float
var _current_heals: float
var _heal_amount : float
var _current_attack_damage : float


### References ###
var limb_object : PackedScene = preload("res://Scenes/components/limb.tscn")
var rnd = RandomNumberGenerator.new()
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
			new_limb.on_hit.connect(_emit_on_limb_hit)

			# Add to a dictionary
			_current_limbs[parent_name] = new_limb


func _generate_visuals(visuals_data : PackedScene) -> Node2D:
	# Remove old visuals
	var old_visuals = self.get_node("Visuals")
	if old_visuals:
		old_visuals.queue_free()

	# Instantiate new visuals
	var new_visuals = visuals_data.instantiate()
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


func _get_total_limb_health() -> float: ## Returns total limb health percentage
	var enemy_limb_health = _get_enemy_limb_health_dict()
	var total_health = util.add_dictionary_values(enemy_limb_health)
	return total_health


func _get_enemy_limb_health_dict() -> Dictionary:
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


func _heal_limb(limb_name : String, amount : float) -> void:
	# Play an animation

	# Heal the limb
	_current_limbs[limb_name].heal_damage(amount)
	
	# Broadcast action
	var heal_message = "Enemy heals its %s!" %limb_name
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


# Generate a function to use when a limb is hit
func _emit_on_limb_hit(hit_message : String) -> void:
	# Play is hit animation
	on_limb_hit.emit(hit_message)


# Actions
func _take_attack_action() -> void:
	var limb_weights = Global.current_player.get_limb_health_dict()
	var best_limb = util.get_smallest_dict_value(limb_weights)
	_attack_player_part(best_limb)
	print("\nBest limb to attack: %s" %best_limb)

func _take_heal_action() -> void:
	# choose best limb to heal from enemy_dict
	var enemy_limb_health = _get_enemy_limb_health_dict()
	var best_limb = util.get_smallest_dict_value(enemy_limb_health)
	_heal_limb(best_limb, _heal_amount)
	print("Best limb to heal: %s" %best_limb)


func _take_defend_action() -> void:
	# play an animation
	# enemy takes reduced or no damage on next turn
	var action_message = "Enemy defends!"
	on_action_completed.emit(action_message)


func _take_run_action() -> void:
	# play an animation
	# RNG to determine run chance, can't run if leg broken
	# if run is best action use RNG to determine if it is successful 
	# play animation and change scene
	var action_message = "Enemy tries to run!"
	on_action_completed.emit(action_message)



# Action chance calculations
func _get_attack_chance() -> float:
	# Get enemy and player total health percentages
	var enemy_total_limbs_health = _get_total_limb_health()
	var player_total_limbs_health = Global.current_player.get_total_limb_health()

	# Calculate the heals remaining and our current speed?
	var heals_remaining = _current_heals / _total_heals
	var speed_check = _current_speed / _max_speed

	# Get attack chance
	var factor = 15
	var attack_chance_percent = (enemy_total_limbs_health + player_total_limbs_health + heals_remaining + speed_check) / factor
	return attack_chance_percent


func _get_heal_chance() -> float:
	# TODO: This is a placeholder calculation
	# Heal note: add 1 if no more heals?
	return _get_attack_chance()


func _get_defend_chance() -> float:
	# TODO: This is a placeholder calculation
	# Defend note: add in 1 if a limb is below 30%?
	return _get_attack_chance()


func _get_run_chance() -> float:
	# Run note: no chance to run if one or more legs are at 0%?
	# Run note: add 1 if a limb is below 20%?

	# Get leg health
	var left_leg_health: float = _get_limb_health_percent("LeftLeg")
	var right_leg_health: float = _get_limb_health_percent("RightLeg")
	var factor = 4

	# Run chance is a percentage of the remaining leg health
	var run_chance_percent = (left_leg_health + right_leg_health) / factor
	return run_chance_percent


### Public Methods ###
func create(new_enemy_data : EnemyData):
	# Set enemy stats
	_max_speed = new_enemy_data.max_speed
	_total_heals = new_enemy_data.total_heals
	_heal_amount = new_enemy_data.heal_amount
	_current_attack_damage = new_enemy_data.attack_damage

	# Generate visuals and get limb points to add limbs to
	var limb_points = _generate_visuals(new_enemy_data.visuals)

	# Generate the enemy's limbs
	_generate_limbs(limb_points, new_enemy_data.limbs)


func end_enemy_turn(turn_manager : TurnManager) -> void:
	# Lock turn change while we wait for timer
	turn_manager.lock_turn_change()
	await get_tree().create_timer(1).timeout	
	turn_manager.unlock_turn_change()

	# Start enemy turn
	var next_turn = TurnManager.TurnType.PLAYER_TURN
	turn_manager.change_turn(next_turn)


func take_enemy_turn(turn_manager : TurnManager):
	# DEBUG
	_debug_log_all_health()
	
	# TODO: add something later calc is a place holder
	# choose best action from dictionary
	var action_weights = {
		"attack" : _get_attack_chance(),
		"heal": _get_heal_chance(),
		"defend": _get_defend_chance(),
		"run": _get_run_chance(),
	}
	var best_action = util.get_largest_dict_value(action_weights)

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
	
	# end turn	
	end_enemy_turn(turn_manager)

### Built in Methods ###
func _process(_delta):
	_process_gauges()