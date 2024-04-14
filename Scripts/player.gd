extends Node2D

func _process(_delta):
	if Global.playerHead <= 0:
		Global.playerHead = 0
	if Global.playerHead >= 100:
		Global.playerHead = 100
		
	if Global.playerRarm <= 0:
		Global.playerRarm = 0
	if Global.playerRarm >= 100:
		Global.playerRarm = 100
		
	if Global.playerLarm <= 0:
		Global.playerLarm = 0
	if Global.playerLarm >= 100:
		Global.playerLarm = 100
		
	if Global.playerLleg <= 0:
		Global.playerLleg = 0
	if Global.playerLleg >= 100:
		Global.playerLleg = 100
		
	if Global.playerRleg <= 0:
		Global.playerRleg = 0
	if Global.playerRleg >= 100:
		Global.playerRleg = 100
		
	if Global.playerTorso <= 0:
		Global.playerTorso = 0
	if Global.playerTorso >= 100:
		Global.playerTorso = 100
