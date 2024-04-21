extends Node

var enemy_defeated = 0

### Enums ###
enum LimbType {
	HEAD,
	TORSO,
	LEFT_ARM,
	RIGHT_ARM,
	LEFT_LEG,
	RIGHT_LEG,
}

enum StatType {
	ATTACK,
	DEFENSE,
	SPEED,
}

var stat_display_data = [
	{
		display_name = "Attack",
		abbreviation = "atk",
	},
	{
		display_name = "Defense",
		abbreviation = "def",
	},
	{
		display_name = "Speed",
		abbreviation = "spd",
	},
]

var setScore = 0
var turnCounter = 0
var enemyAction = ""
var setCombo = 0

var current_turn_manager : TurnManager
var current_enemy: Enemy
var current_enemy_data : EnemyData
var current_player : Player # May want to change from global later
