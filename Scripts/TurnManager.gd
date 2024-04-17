class_name TurnManager
extends Node

### Signals ###
signal player_turn_started()
signal enemy_turn_started()

### Enums ###
enum TurnType {
	NO_TURN,
	ENEMY_TURN,
	PLAYER_TURN,
}

### Public Variables ###
var current_turn : TurnType :
	get: return current_turn
	set(value) : current_turn = _set_turn(value)


### Private Varaibles ###
var _can_change_turn : bool = true

### Public Method ###
func lock_turn_change() -> void:
	_can_change_turn = false
	
	# TODO: This should be handled by player script in future
	Global.can_player_act = _can_change_turn


func unlock_turn_change() -> void:
	_can_change_turn = true

	# TODO: This should be handled by player script in future
	Global.can_player_act = _can_change_turn


func change_turn(turn : TurnType) -> void:
	# Change turns
	current_turn = turn


func start_player_turn() -> void:
	print("\n\n-------------------\nStarting player turn:")
	player_turn_started.emit()


func start_enemy_turn() -> void:
	print("\n\n-------------------\nStarting enemy turn:\n")
	enemy_turn_started.emit()


### Private Methods ###
func _set_turn(value : TurnType) -> TurnType:
	# Make sure we can change the turn
	if not _can_change_turn:
		print("Tried to change turn but cannot")
		return current_turn

	# Trigger any logic for changing turns
	match value:
		TurnType.PLAYER_TURN: start_player_turn()
		TurnType.ENEMY_TURN: start_enemy_turn()

	return value