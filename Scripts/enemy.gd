extends Node2D

@export var speed: float = 0.0
@export var maxSpeed: float = 10.0
@export var totalHeals: float = 3.0
@export var currentHeals: float = 0.0
var turnmanager = preload("res://Resources/TurnManager.tres")

		
func _enemy_turn():
		
	# check speed and chance for successful run
	var speedCheck: float = speed / maxSpeed
	if Global.enemyLleg == 0 or Global.enemyRleg == 0:
		speedCheck = 0.0
		
	# check for heals left
	var healsRemaining: float = currentHeals / totalHeals
	
	# check enemy limb health
	var enemyHeadHealth: float = Global.enemyHead / 100
	var enemyTorsoHealth: float = Global.enemyTorso / 100
	var enemyLarmHealth: float = Global.enemyLarm / 100
	var enemyRarmHealth: float = Global.enemyRarm / 100
	var enemyLlegHealth: float = Global.enemyLleg / 100
	var enemyRlegHealth: float = Global.enemyRleg / 100
	var limbsHealth = enemyHeadHealth + enemyTorsoHealth + enemyLlegHealth + enemyRlegHealth + enemyRarmHealth + enemyLarmHealth
	
		# check player limb health
	var playerHeadHealth: float = Global.playerHead / 100
	var playerTorsoHealth: float = Global.playerTorso / 100
	var playerLarmHealth: float = Global.playerLarm / 100
	var playerRarmHealth: float = Global.playerRarm / 100
	var playerLlegHealth: float = Global.playerLleg / 100
	var playerRlegHealth: float = Global.playerRleg / 100
	var playerLimbHealthAvg = (playerHeadHealth + playerTorsoHealth + playerLlegHealth + playerRlegHealth + playerRarmHealth + playerLarmHealth)/6
	
	# calculate avg for each action
	var headCalc:float = (limbsHealth + (1-playerHeadHealth) + healsRemaining + speedCheck)/9
	print(headCalc)
	var torsoCalc:float = (limbsHealth + (1-playerTorsoHealth) + healsRemaining + speedCheck + 100)/9
	print(torsoCalc)
	var larmCalc:float = (limbsHealth + (1-playerLarmHealth) + healsRemaining + speedCheck)/9
	print(larmCalc)
	var rarmCalc:float = (limbsHealth + (1-playerRarmHealth) + healsRemaining + speedCheck)/9
	print(rarmCalc)
	var llegCalc:float = (limbsHealth + (1-playerLlegHealth) + healsRemaining + speedCheck)/9
	print(llegCalc)
	var rlegCalc:float = (limbsHealth + (1-playerRlegHealth) + healsRemaining + speedCheck)/9
	print(rlegCalc)
	
	var healCalc:float = (limbsHealth + playerLimbHealthAvg + healsRemaining + speedCheck)/9
	# add in 1 if a limb is below 30%
	print(healCalc)
	var defendCalc:float = (limbsHealth + playerLimbHealthAvg + healsRemaining + speedCheck)/9
	# add 1 if a limb is below 20%
	# add 1 if no more heals
	print(defendCalc)
	var runCalc:float = (enemyLlegHealth + enemyRlegHealth) / 4
	# add something later above calc is a place holder
	# no chance to run if one or more legs are at 0%
	print(runCalc)

	# comparing values
	var dict = {"headCalc": headCalc, 
				"torsoCalc": torsoCalc, 
				"llegCalc": llegCalc, 
				"rlegCalc": rlegCalc, 
				"larmCalc": larmCalc, 
				"rarmCalc": rarmCalc, 
				"healCalc": healCalc, 
				"defendCalc": defendCalc, 
				"runCalc": runCalc}
				
	var bestAction = _find_best_action(dict)
	print(bestAction)        # prints "d"
	print(dict[bestAction])  # prints "55"
	
func _find_best_action(dict):
	var max_val = -999999
	var bestAction
	for i in dict:
		var val =  dict[i]
		if val > max_val:
			max_val = val
			bestAction = i
		return bestAction
