extends Node2D

@export var speed: float = 0.0
@export var maxSpeed: float = 10.0
@export var totalHeals: float = 3.0
@export var currentHeals: float = 0.0
var turnmanager = preload("res://Resources/TurnManager.tres")
var rnd = RandomNumberGenerator.new()
		
		
func _enemy_turn():
		
	# check speed and chance for successful run
	var speedCheck: float = speed / maxSpeed
		
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
	
	# calculate avg for each attack action
	var headCalc:float = (limbsHealth + (1-playerHeadHealth) + healsRemaining + speedCheck)/9
	print(headCalc)
	var torsoCalc:float = (limbsHealth + (1-playerTorsoHealth) + healsRemaining + speedCheck)/9
	print(torsoCalc)
	var larmCalc:float = (limbsHealth + (1-playerLarmHealth) + healsRemaining + speedCheck)/9
	print(larmCalc)
	var rarmCalc:float = (limbsHealth + (1-playerRarmHealth) + healsRemaining + speedCheck)/9
	print(rarmCalc)
	var llegCalc:float = (limbsHealth + (1-playerLlegHealth) + healsRemaining + speedCheck)/9
	print(llegCalc)
	var rlegCalc:float = (limbsHealth + (1-playerRlegHealth) + healsRemaining + speedCheck)/9
	print(rlegCalc)
	# calculate avg for each defensive action
	var healCalc:float = (limbsHealth + playerLimbHealthAvg + healsRemaining + speedCheck)/15
	# add in 1 if a limb is below 30%?
	print(healCalc)
	var defendCalc:float = (limbsHealth + playerLimbHealthAvg + healsRemaining + speedCheck)/15
	# add 1 if a limb is below 20%?
	# add 1 if no more heals?
	print(defendCalc)
	var runCalc:float = (enemyLlegHealth + enemyRlegHealth) / 4
	# add something later above calc is a place holder
	# no chance to run if one or more legs are at 0%?
	print(runCalc)

	# comparing values
	var enemy_dict = {"enemyHeadHealth": enemyHeadHealth, 
				"enemyTorsoHealth": enemyTorsoHealth, 
				"enemyLlegHealth": enemyLlegHealth, 
				"enemyRlegHealth": enemyRlegHealth, 
				"enemyLarmHealth": enemyLarmHealth, 
				"enemyRarmHealth": enemyRarmHealth} 
				
	var dict = {"headCalc": headCalc, 
				"torsoCalc": torsoCalc, 
				"llegCalc": llegCalc, 
				"rlegCalc": rlegCalc, 
				"larmCalc": larmCalc, 
				"rarmCalc": rarmCalc, 
				"healCalc": healCalc, 
				"defendCalc": defendCalc, 
				"runCalc": runCalc}

	# choose best action from dictionary
	var bestHeal = _find_best_heal(enemy_dict)
	var bestAction = _find_best_action(dict)
	print(bestAction)
	print(bestHeal)
	if _find_best_action(dict) == "headCalc":
		#play an animation
		Global.playerHead -= 25
		Global.enemyAction = "Enemy attacks your head!"
	if _find_best_action(dict) == "torsoCalc":
		#play an animation
		Global.playerTorso -= 25
		Global.enemyAction = "Enemy attacks your torso!"
	if _find_best_action(dict) == "rarmCalc":
		#play an animation
		Global.playerRarm -= 25
		Global.enemyAction = "Enemy attacks your right arm!"
	if _find_best_action(dict) == "larmCalc":
		#play an animation
		Global.playerLarm -= 25
		Global.enemyAction = "Enemy attacks your left arm!"
	if _find_best_action(dict) == "rlegCalc":
		#play an animation
		Global.playerRleg -= 25
		Global.enemyAction = "Enemy attacks your right leg!"
	if _find_best_action(dict) == "llegCalc":
		#play an animation
		Global.playerLleg -= 25
		Global.enemyAction = "Enemy attacks your left leg!"
		
### HEAL CALCS ###
	if _find_best_action(dict) == "healCalc":
		#play an animation
		# choose best limb to heal from enemy_dict
		if _find_best_heal(enemy_dict) == "enemyHeadHealth":
			Global.enemyHead += 25
			Global.enemyAction = "Enemy heals its head!"
		if _find_best_heal(enemy_dict) == "enemyTorsoHealth":
			Global.enemyTorso += 25
			Global.enemyAction = "Enemy heals its torso!"
		if _find_best_heal(enemy_dict) == "enemyLarmHealth":
			Global.enemyLarm += 25
			Global.enemyAction = "Enemy heals its left arm!"
		if _find_best_heal(enemy_dict) == "enemyRarmHealth":
			Global.enemyRarm += 25
			Global.enemyAction = "Enemy heals its right arm!"
		if _find_best_heal(enemy_dict) == "enemyLlegHealth":
			Global.enemyLleg += 25
			Global.enemyAction = "Enemy heals its left leg!"
		if _find_best_heal(enemy_dict) == "enemyRlegHealth":
			Global.enemyRleg += 25
			Global.enemyAction = "Enemy heals its right leg!"
### END HEAL CALCS ###

	if _find_best_action(dict) == "defendCalc":
		# play an animation
		# enemy takes reduced or no damage on next turn
		Global.enemyAction = "Enemy defends!"
	if _find_best_action(dict) == "runCalc":
		# play an animation
		# RNG to determine run chance, can't run if leg broken
		Global.enemyAction = "Enemy tries to run!"
		# if run is best action use RNG to determine if it is successful 
		# play animation and change scene
	
	# if 2 calcs are equal, randomly choose any of them for easier difficulty
	# choose attack over defense action for harder difficulty
	# choose attack over defend and attack lowest health limb for harder difficulty
	# if debuffs/buffs added, choose buffs for hardest difficulty 

# compare values in dictionary
func _find_best_action(dict):
	var max_val = -999999
	var bestAction
	for i in dict:
		var val =  dict[i]
		if val > max_val:
			max_val = val
			bestAction = i
	return bestAction

func _find_best_heal(enemy_dict):
	var min_val = 999999
	var bestHeal
	for i in enemy_dict:
		var val =  enemy_dict[i]
		if val < min_val:
			min_val = val
			bestHeal = i
	return bestHeal
