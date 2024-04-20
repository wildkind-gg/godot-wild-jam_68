class_name Player
extends Node2D


## Include ###
var util : Util = Util.new()


### Constants ###
const MAX_PERCENT : float = 100.0
const MIN_HEALTH : float = 0.0

### Signals ###
signal on_death(death_message : String)
signal broadcast_message(message : String)


## Public Variables ###
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
@onready var animation_player = $AnimationPlayer

### Exports ###
@export var attack_damage : float = 25.0
@export var defense_percent : float = 0.75


## Private Variables ###
var _is_defending : bool = false


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


func get_flipped_limb_health_percent_dict() -> Dictionary: # Returns dictionary of player's limb healths
	# Player limb health dictionary
	var current_limb_health_percent = {}
	for key in current_limb_health:
		var max_healh = max_limb_health[key]
		var current_health = current_limb_health[key]
		
		# Only track limbs that are alive
		if current_health / max_healh > 0:
			# Track inverted percent to use as probablity table for targeting
			# Start at 1.2 to make limbs at 100% health have 20% chance of being targeted still
			current_limb_health_percent[key] = 1.2 - (current_health / max_healh)
			current_limb_health_percent[key] = max(0, current_limb_health_percent[key])

	return current_limb_health_percent


# actions
func take_attack_action(limb : Limb) -> void:
	if not Global.current_turn_manager.is_players_turn():
		return

	# Play animation	
	animation_player.play("tackle")

	# Complete attack action method (need new one with new limb)
	var _complete_attack_action = func(anim_name):
		if anim_name == "tackle":
			var damage = _damage_calculation()
			limb.take_damage(damage)
	
	# Disconnect old connected method (as we are connecting a new one)
	var connections = animation_player.get_signal_connection_list("animation_finished")
	for con in connections:
		animation_player.disconnect("animation_finished", con.callable)
	
	# Connect new method
	animation_player.animation_finished.connect(_complete_attack_action)


func take_defend_action() -> void:
	_is_defending = true

	var defend_message = "You defend yourself"
	broadcast_message.emit(defend_message)


# Limb helpers
func take_damage(amount : float, limb : String) -> void:
	# Reduce incoming damage if defending
	if _is_defending:
		# Reduce damage
		var reduction_amount = amount * defense_percent
		amount -= reduction_amount

		# Broadcast the reduction
		var message = "Incoming damage reduced by %d" %reduction_amount
		broadcast_message.emit(message)

		# No longer defend (since we just defended)
		_is_defending = false
	
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


	# Animate
	animation_player.play("hit")

	# Check if we are still alive
	if not _is_alive():
		destroy()


func create() -> void:
	for key in max_limb_health:
		var max_health = max_limb_health[key]
		current_limb_health[key] = max_health
	
	_process_gauges()
