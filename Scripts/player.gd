extends Node2D

func _process(_delta):
	Global.playerHead = clamp(Global.playerHead,0,100.0)
	Global.playerRarm = clamp(Global.playerRarm,0,100.0)
	Global.playerLarm = clamp(Global.playerLarm,0,100.0)
	Global.playerLleg = clamp(Global.playerLleg,0,100.0)
	Global.playerRleg = clamp(Global.playerRleg,0,100.0)
	Global.playerTorso = clamp(Global.playerTorso,0,100.0)
	
	
	$Player_Limbs/Player_Head.value = Global.playerHead
	if Global.playerHead == 100:
		$Player_Limbs/Player_Head.hide()
	else:
		$Player_Limbs/Player_Head.show()


	$Player_Limbs/Player_Rarm.value = Global.playerRarm
	if Global.playerRarm == 100:
		$Player_Limbs/Player_Rarm.hide()
	else:
		$Player_Limbs/Player_Rarm.show()

	$Player_Limbs/Player_Larm.value = Global.playerLarm
	if Global.playerLarm == 100:
		$Player_Limbs/Player_Larm.hide()
	else:
		$Player_Limbs/Player_Larm.show()
		
	$Player_Limbs/Player_Lleg.value = Global.playerLleg
	if Global.playerLleg == 100:
		$Player_Limbs/Player_Lleg.hide()
	else:
		$Player_Limbs/Player_Lleg.show()
		
	$Player_Limbs/Player_Rleg.value = Global.playerRleg
	if Global.playerRleg == 100:
		$Player_Limbs/Player_Rleg.hide()
	else:
		$Player_Limbs/Player_Rleg.show()
		
	$Player_Limbs/Player_Torso.value = Global.playerTorso
	if Global.playerTorso == 100:
		$Player_Limbs/Player_Torso.hide()
	else:
		$Player_Limbs/Player_Torso.show()
