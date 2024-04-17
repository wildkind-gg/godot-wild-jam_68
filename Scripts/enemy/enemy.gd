extends Node2D

### Signals ###
signal on_action_completed(action_message : String)
signal on_limb_hit(hit_message : String)

### Exports ###
@export var enemy_data : EnemyData


### Private Variables ###
var _current_limbs : Dictionary
var _max_speed: float
var _current_speed: float
var _total_heals: float
var _current_heals: float
var _current_attack_damage : float


### References ###
var limb_object : PackedScene = preload("res://Scenes/components/limb.tscn")
var rnd = RandomNumberGenerator.new()


### Private Methods ###
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


func _calculate_average(limb_health : float, player_health : float, heals_remaining : float, current_speed : float) -> float:
	var factor = 9
	var player_calc = 1 - player_health
	var average = (limb_health + player_calc + heals_remaining + current_speed) / factor
	return average


func _get_limb_health(limb_name : String) -> float:
	return _current_limbs[limb_name].get_current_health()


func _get_limb_health_percent(limb_name : String) -> float:
	var percent_factor = 100
	var health = _get_limb_health(limb_name)
	return health / percent_factor


func _debug_log_all_health() -> void:
	print("Limb Health:")
	for key in _current_limbs:
		var limb_health = _get_limb_health(key)
		print("- %s: %d" %[key, limb_health])


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
	var damage = _damage_calculation()
	
	# Play an animation

	# TODO: Create player object with a take damage
	# method that does this instead
	Global[part_name] -= damage
	
	# Broadcast action
	var action_message = "Enemy attacks %s" %part_name
	on_action_completed.emit(action_message)


# Generate a function to use when a limb is hit
func _emit_on_limb_hit(hit_message : String) -> void:
	# Play is hit animation
	on_limb_hit.emit(hit_message)


### Public Methods ###
func create(new_enemy_data : EnemyData):
	# Set enemy stats
	_max_speed = new_enemy_data.max_speed
	_total_heals = new_enemy_data.total_heals
	_current_attack_damage = new_enemy_data.attack_damage

	# Get limb data and points
	var limb_points := $LimbPoints

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
	# check _current_speed and chance for successful run
	var speedCheck: float = _current_speed / _max_speed
		
	# check for heals left
	var healsRemaining: float = _current_heals / _total_heals
	
	# check enemy limb health
	var head_health: float = _get_limb_health_percent("Head")
	var torso_health: float = _get_limb_health_percent("Torso")
	var left_arm_health: float = _get_limb_health_percent("LeftArm")
	var right_arm_health: float = _get_limb_health_percent("RightArm")
	var left_leg_health: float = _get_limb_health_percent("LeftLeg")
	var right_leg_health: float = _get_limb_health_percent("RightLeg")
	var total_limbs_health = head_health + torso_health + left_leg_health + right_leg_health + right_arm_health + left_arm_health
	
	# DEBUG
	_debug_log_all_health()

	# check player limb health
	var playerHeadHealth: float = Global.playerHead / 100
	var playerTorsoHealth: float = Global.playerTorso / 100
	var playerLarmHealth: float = Global.playerLarm / 100
	var playerRarmHealth: float = Global.playerRarm / 100
	var playerLlegHealth: float = Global.playerLleg / 100
	var playerRlegHealth: float = Global.playerRleg / 100
	var playerLimbHealthAvg = (playerHeadHealth + playerTorsoHealth + playerLlegHealth + playerRlegHealth + playerRarmHealth + playerLarmHealth)/6
	
	# calculate avg for each attack action
	var headCalc = _calculate_average(total_limbs_health, playerHeadHealth, healsRemaining, speedCheck)
	var torsoCalc = _calculate_average(total_limbs_health, playerTorsoHealth, healsRemaining, speedCheck)
	var larmCalc = _calculate_average(total_limbs_health, playerLarmHealth, healsRemaining, speedCheck)
	var rarmCalc = _calculate_average(total_limbs_health, playerRarmHealth, healsRemaining, speedCheck)
	var llegCalc = _calculate_average(total_limbs_health, playerLlegHealth, healsRemaining, speedCheck)
	var rlegCalc = _calculate_average(total_limbs_health, playerRlegHealth, healsRemaining, speedCheck)

	# calculate avg for each defensive action
	var healCalc:float = (total_limbs_health + playerLimbHealthAvg + healsRemaining + speedCheck)/15
	
	# add in 1 if a limb is below 30%?
	var defendCalc:float = (total_limbs_health + playerLimbHealthAvg + healsRemaining + speedCheck)/15
	
	# add 1 if a limb is below 20%?
	# add 1 if no more heals?
	var runCalc:float = (left_leg_health + right_leg_health) / 4
	
	# add something later above calc is a place holder
	# no chance to run if one or more legs are at 0%?

	# comparing values
	var enemy_dict = {"enemyHeadHealth": head_health, 
				"enemyTorsoHealth": torso_health, 
				"enemyLlegHealth": left_leg_health, 
				"enemyRlegHealth": right_leg_health, 
				"enemyLarmHealth": left_arm_health, 
				"enemyRarmHealth": right_arm_health} 
				
	var dict = {"headCalc": headCalc, 
				"torsoCalc": torsoCalc, 
				"llegCalc": llegCalc, 
				"rlegCalc": rlegCalc, 
				"larmCalc": larmCalc, 
				"rarmCalc": rarmCalc, 
				"healCalc": healCalc, 
				"defendCalc": defendCalc, 
				"runCalc": runCalc}

	# choose best action from dictionary
	var bestHeal = _find_best_heal(enemy_dict)
	var bestAction = _find_best_action(dict)
	print("\nBest action: %s" %bestAction)
	print("Best heal: %s" %bestHeal)

	if _find_best_action(dict) == "headCalc":
		_attack_player_part("playerHead")
	if _find_best_action(dict) == "torsoCalc":
		_attack_player_part("playerTorso")
	if _find_best_action(dict) == "rarmCalc":
		_attack_player_part("playerRarm")
	if _find_best_action(dict) == "larmCalc":
		_attack_player_part("playerLarm")
	if _find_best_action(dict) == "rlegCalc":
		_attack_player_part("playerRleg")
	if _find_best_action(dict) == "llegCalc":
		_attack_player_part("playerLleg")
		
	### HEAL CALCS ###
	var heal_amount = 25 # TODO: Add to enemy data
	if _find_best_action(dict) == "healCalc":
		# choose best limb to heal from enemy_dict
		if _find_best_heal(enemy_dict) == "enemyHeadHealth":
			_heal_limb("Head", heal_amount)
		if _find_best_heal(enemy_dict) == "enemyTorsoHealth":
			_heal_limb("Torso", heal_amount)
		if _find_best_heal(enemy_dict) == "enemyLarmHealth":
			_heal_limb("LeftArm", heal_amount)
		if _find_best_heal(enemy_dict) == "enemyRarmHealth":
			_heal_limb("RightArm", heal_amount)
		if _find_best_heal(enemy_dict) == "enemyLlegHealth":
			_heal_limb("LeftLeg", heal_amount)
		if _find_best_heal(enemy_dict) == "enemyRlegHealth":
			_heal_limb("RightLeg", heal_amount)
	### END HEAL CALCS ###

	if _find_best_action(dict) == "defendCalc":
		# play an animation
		# enemy takes reduced or no damage on next turn
		Global.enemyAction = "Enemy defends!"
	if _find_best_action(dict) == "runCalc":
		# play an animation
		# RNG to determine run chance, can't run if leg broken
		Global.enemyAction = "Enemy tries to run!"
		# if run is best action use RNG to determine if it is successful 
		# play animation and change scene
	
	# if 2 calcs are equal, randomly choose any of them for easier difficulty
	# choose attack over defense action for harder difficulty
	# choose attack over defend and attack lowest health limb for harder difficulty
	# if debuffs/buffs added, choose buffs for hardest difficulty 
	
	# end turn	
	end_enemy_turn(turn_manager)


# compare values in dictionary
func _find_best_action(dict):
	var max_val = -999999
	var bestAction
	for i in dict:
		var val =  dict[i]
		if val > max_val:
			max_val = val
			bestAction = i
	return bestAction

func _find_best_heal(enemy_dict):
	var min_val = 999999
	var bestHeal
	for i in enemy_dict:
		var val =  enemy_dict[i]
		if val < min_val:
			min_val = val
			bestHeal = i
	return bestHeal
