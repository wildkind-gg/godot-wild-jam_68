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


var playerHead:float = 100.0
var playerLarm:float = 100.0
var playerRarm:float = 100.0
var playerLleg:float = 100.0
var playerRleg:float = 100.0
var playerTorso:float = 100.0

var setScore = 0
var turnCounter = 0
var enemyAction = ""

var current_enemy : EnemyData
var current_player : Player # May want to change from global later