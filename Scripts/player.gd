extends Node2D

func _process(_delta):
	Global.playerHead = clamp(Global.playerHead,0,100)
	Global.playerRarm = clamp(Global.playerRarm,0,100)
	Global.playerLarm = clamp(Global.playerLarm,0,100)
	Global.playerLleg = clamp(Global.playerLleg,0,100)
	Global.playerRleg = clamp(Global.playerRleg,0,100)
	Global.playerTorso = clamp(Global.playerTorso,0,100)
