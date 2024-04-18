class_name Player
extends Node2D


## Include ###
var util : Util = Util.new()


### Constants ###
const MAX_PERCENT : float = 100.0
const MIN_HEALTH : float = 0.0

### Signals ###
signal on_death(death_message : String)


## Public Variables ###
var current_turn_manager : TurnManager
var max_limb_health = {
	"Head" = 60.0,
	"Torso" = 60.0,
	"Right Arm" = 60.0,
	"Left Arm" = 60.0,
	"Right Leg" = 60.0,
	"Left Leg" = 60.0,
}
var current_limb_health : Dictionary

### On Ready ###
@onready var _limb_gauges = {
	"Head" = $Player_Limbs/Player_Head,
	"Torso" = $Player_Limbs/Player_Torso,
	"Right Arm" = $Player_Limbs/Player_Rarm,
	"Left Arm" = $Player_Limbs/Player_Larm,
	"Right Leg" = $Player_Limbs/Player_Rleg,
	"Left Leg" = $Player_Limbs/Player_Lleg,
}


### Exports ###
@export var attack_damage : float = 25.0


### Private Methods ###
# Debug
func _debug_log_all_health() -> void:
	print("[Player] Limb Health:")
	for key in current_limb_health:
		var health = current_limb_health[key]
		print("- %s: %f" %[key, health])


# Getters
func _is_alive() -> bool:
	return get_total_limb_health_percent() > 0


# Gauge helpers
func _process_gauges() -> void:
	for key in _limb_gauges:
		# Get data
		var ui_element = _limb_gauges[key]
		var value = get_limb_health_percent(key) * 100
		
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
func destroy() -> void:
	# Play death animation

	# Tell batlle that player died
	var death_message = "You have been defeated"
	on_death.emit(death_message)


# Getters
func get_total_limb_health_percent() -> float: ## Returns player's total limb health percentage
	var total_health = util.add_dictionary_values(current_limb_health)
	var max_total_health = util.add_dictionary_values(max_limb_health)
	return total_health / max_total_health


func get_limb_health_percent(limb : String) -> float:
	var current_health = current_limb_health[limb]
	var max_health = max_limb_health[limb]
	return current_health / max_health


func get_limb_health_percent_dict() -> Dictionary: # Returns dictionary of player's limb healths
	# Player limb health dictionary
	var current_limb_health_percent = {}
	for key in current_limb_health:
		var max_healh = max_limb_health[key]
		var current_health = current_limb_health[key]
		current_limb_health_percent[key] = current_health / max_healh

	return current_limb_health_percent


# actions
func take_attack_action(limb : Limb) -> void:
	if not current_turn_manager.is_players_turn():
		return
	
	var damage = _damage_calculation()
	limb.take_damage(damage)


# Limb helpers
func take_damage(amount : float, limb : String) -> void:
	# Calculate next value
	var new_value = current_limb_health[limb] - amount

	# Don't go negative (normally MIN_HEALTH = 0)
	if new_value >= MIN_HEALTH:
		current_limb_health[limb] = new_value
	else:
		current_limb_health[limb] = MIN_HEALTH

	# Update UI
	_process_gauges()

	# DEBUG
	# _debug_log_all_health()

	# Check if we are still alive
	if not _is_alive():
		destroy()


func create(turn_manager : TurnManager) -> void:
	for key in max_limb_health:
		var max_health = max_limb_health[key]
		current_limb_health[key] = max_health
	
	current_turn_manager = turn_manager
	_process_gauges()
