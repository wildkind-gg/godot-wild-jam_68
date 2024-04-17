class_name Player
extends Node2D


## Include ###
var util : Util = Util.new()


### Constants ###
const MAX_PERCENT : float = 100.0
const MIN_HEALTH : float = 0.0


### On Ready ###
@onready var _limb_gauges = {
	"playerHead" = $Player_Limbs/Player_Head,
	"playerTorso" = $Player_Limbs/Player_Torso,
	"playerRarm" = $Player_Limbs/Player_Rarm,
	"playerLarm" = $Player_Limbs/Player_Larm,
	"playerRleg" = $Player_Limbs/Player_Rleg,
	"playerLleg" = $Player_Limbs/Player_Lleg,
}


### Private Methods ###
# Debug
func _debug_log_all_health() -> void:
	print("[Player] Limb Health:")
	for key in _limb_gauges:
		var limb_health = Global[key]
		print("- %s: %d" %[key, limb_health])


# Gauge helpers
func _get_clamped_limb_health(limb_name : String) -> float:
	var value = Global[limb_name]
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


### Public Methods ###
# Getters
func get_total_limb_health() -> float: ## Returns player's total limb health percentage
	var player_limb_health = get_limb_health_dict()
	var total_health = util.add_dictionary_values(player_limb_health)
	return total_health


func get_limb_health_dict() -> Dictionary: # Returns dictionary of player's limb healths
	# Player limb health dictionary
	var percentage_factor = 100
	var player_limb_health = {
		"playerHead": Global.playerHead / percentage_factor,
		"playerTorso": Global.playerTorso / percentage_factor,
		"playerLarm": Global.playerLarm / percentage_factor,
		"playerRarm": Global.playerRarm / percentage_factor,
		"playerLleg": Global.playerLleg / percentage_factor, 
		"playerRleg": Global.playerRleg / percentage_factor, 
	}

	return player_limb_health


# Limb helpers
func take_damage(amount : float, limb : String) -> void:
	# DEBUG
	_debug_log_all_health()

	# Calculate next value
	var new_value = Global[limb] - amount

	# Don't go negative (normally MIN_HEALTH = 0)
	if new_value >= MIN_HEALTH:
		Global[limb] = new_value
	else:
		Global[limb] = MIN_HEALTH


### Built in Methods ###
func _process(_delta):
	# For processing the ui
	_process_gauges()
