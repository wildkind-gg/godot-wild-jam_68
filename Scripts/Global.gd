extends Node

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

var setScore = 0
var turnCounter = 0
var enemyAction = ""
var setCombo = 0

var current_enemy : EnemyData
var current_player : Player # May want to change from global later
