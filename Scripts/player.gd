class_name Player
extends Node2D


## Include ###
var util : Util = Util.new()


### Constants ###
const MAX_PERCENT : float = 100.0
const MIN_HEALTH : float = 0.0


## Public Variables ###
var current_turn_manager : TurnManager
var limb_health = {
	"Head" = 100.0,
	"Torso" = 100.0,
	"RightArm" = 100.0,
	"LeftArm" = 100.0,
	"RightLeg" = 100.0,
	"LeftLeg" = 100.0,
}

### On Ready ###
@onready var _limb_gauges = {
	"Head" = $Player_Limbs/Player_Head,
	"Torso" = $Player_Limbs/Player_Torso,
	"RightArm" = $Player_Limbs/Player_Rarm,
	"LeftArm" = $Player_Limbs/Player_Larm,
	"RightLeg" = $Player_Limbs/Player_Rleg,
	"LeftLeg" = $Player_Limbs/Player_Lleg,
}


### Exports ###
@export var attack_damage : float = 25


### Private Methods ###
# Debug
func _debug_log_all_health() -> void:
	print("[Player] Limb Health:")
	for key in limb_health:
		var health = limb_health[key]
		print("- %s: %d" %[key, health])


# Gauge helpers
func _get_clamped_limb_health(limb_name : String) -> float:
	var value = limb_health[limb_name]
	return clamp(value, 0, MAX_PERCENT)


func _process_gauges() -> void:
	for key in _limb_gauges:
		# Get data
		var ui_element = _limb_gauges[key]
		var value = _get_clamped_limb_health(key)
		
		# Set ui value
		ui_element.value = value
		
		# Check to hide
		if value == MAX_PERCENT:
			ui_element.hide()
		else:
			ui_element.show()


# Action helpers
func _damage_calculation() -> float:
	# Add any other damage calculations here
	var base_damage = attack_damage
	return base_damage 


### Public Methods ###
# Getters
func get_total_limb_health() -> float: ## Returns player's total limb health percentage
	var player_limb_health = get_limb_health_dict()
	var total_health = util.add_dictionary_values(player_limb_health)
	return total_health


func get_limb_health_dict() -> Dictionary: # Returns dictionary of player's limb healths
	# Player limb health dictionary
	var percentage_factor = 100
	var limb_health_percent = {}
	for key in limb_health:
		var health = limb_health[key]
		limb_health_percent[key] = health / percentage_factor

	return limb_health_percent


# actions
func take_attack_action(limb : Limb) -> void:
	if not current_turn_manager.is_players_turn():
		return
	
	var damage = _damage_calculation()
	limb.take_damage(damage)


# Limb helpers
func take_damage(amount : float, limb : String) -> void:
	# DEBUG
	_debug_log_all_health()

	# Calculate next value
	var new_value = limb_health[limb] - amount

	# Don't go negative (normally MIN_HEALTH = 0)
	if new_value >= MIN_HEALTH:
		limb_health[limb] = new_value
	else:
		limb_health[limb] = MIN_HEALTH

	# Update UI
	_process_gauges()


func create(turn_manager : TurnManager) -> void:
	current_turn_manager = turn_manager
	_process_gauges()
