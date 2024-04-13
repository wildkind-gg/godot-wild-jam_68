extends AudioStreamPlayer

class_name TurnManager

enum {ENEMY_TURN, PLAYER_TURN}

var turn : int:
	get: return turn
	set(value):
		turn = value
		match turn:
			PLAYER_TURN: emit_signal("player_turn_started")
			ENEMY_TURN: emit_signal("enemy_turn_started")

signal player_turn_started()
signal enemy_turn_started()
