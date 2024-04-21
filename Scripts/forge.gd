extends Node2D

var score = 0
var combo = 0

var maxCombo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0

var bpm = 120

var song_position = 0.0
var song_position_in_beats = 0
var last_spawned_beat = 0
var sec_per_beat = 60.0 / bpm

var spawn_1_beat = 0
var spawn_2_beat = 0
var spawn_3_beat = 1
var spawn_4_beat = 0

var lane = 0
var rand = 0
var note = load("res://Scenes/rhythm_forge/note.tscn")

func _ready():
	$Combo.text = "Combo: 0"
	ForgeMusic.stop()
	BattleMusic.stop()
	MenuMusic.stop()
	randomize()
	#$Conductor.play_with_beat_offset(8)
	$Conductor.seek(120) # sets the position from which audio will be played, in seconds
	$ComboExclamation.text = ""
	
func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://Scenes/menus/main_menu.tscn")
	print(song_position_in_beats)
	$Score.text = "Score: " + "%s" %score
	

func _input(event):
	if event.is_action("escape"):
		if get_tree().change_scene_to_file("res://Scenes/main_menu.tscn") != OK:
			print("Error changing scene to Menu")

func _on_conductor_measure_sig(pos):
	if pos == 1:
		_spawn_notes(spawn_1_beat)
	if pos == 2:
		_spawn_notes(spawn_2_beat)
	if pos == 3:
		_spawn_notes(spawn_3_beat)
	if pos == 4:
		_spawn_notes(spawn_4_beat)

func _on_conductor_beat(pos):
	song_position_in_beats = pos
	if song_position_in_beats > 24:
		spawn_1_beat = 1
		spawn_2_beat = 1
		spawn_3_beat = 1
		spawn_4_beat = 1
	if song_position_in_beats > 78:
		spawn_1_beat = 2
		spawn_2_beat = 1
		spawn_3_beat = 1
		spawn_4_beat = 2
	if song_position_in_beats > 132:
		spawn_1_beat = 1
		spawn_2_beat = 2
		spawn_3_beat = 1
		spawn_4_beat = 2
	if song_position_in_beats > 162:
		spawn_1_beat = 2
		spawn_2_beat = 2
		spawn_3_beat = 1
		spawn_4_beat = 1
	if song_position_in_beats > 194:
		spawn_1_beat = 2
		spawn_2_beat = 2
		spawn_3_beat = 1
		spawn_4_beat = 2
	if song_position_in_beats > 228:
		spawn_1_beat = 1
		spawn_2_beat = 2
		spawn_3_beat = 1
		spawn_4_beat = 2
	if song_position_in_beats > 251:
		spawn_1_beat = 0
		spawn_2_beat = 0
		spawn_3_beat = 0
		spawn_4_beat = 0
	if song_position_in_beats > 288:
		spawn_1_beat = 0
		spawn_2_beat = 2
		spawn_3_beat = 0
		spawn_4_beat = 2
	if song_position_in_beats > 302:
		spawn_1_beat = 3
		spawn_2_beat = 2
		spawn_3_beat = 2
		spawn_4_beat = 1
	if song_position_in_beats > 380:
		spawn_1_beat = 0
		spawn_2_beat = 0
		spawn_3_beat = 0
		spawn_4_beat = 0
	if song_position_in_beats > 384:
		spawn_1_beat = 0
		spawn_2_beat = 0
		spawn_3_beat = 0
		spawn_4_beat = 0
	if song_position_in_beats > 404:
		Global.missed = missed
		if get_tree().change_scene_to_file("res://Scenes/end_forge.tscn") != OK:
			print("Error changing scene to End")
		
func _spawn_notes(to_spawn):
	if to_spawn > 0:
		lane = randi() % 3
		randomize()
		var instance = note.instantiate()
		instance._initialize(lane)
		add_child(instance)
	if to_spawn > 1:
		while rand == lane:
			rand = randi() % 3
			randomize()
		lane = rand
		var instance = note.instantiate()
		instance._initialize(lane)
		add_child(instance)
		
func _increment_score(by):
	if by > 0:
		combo += 1
	else:
		combo = 0
	if by == 3:
		great += 1
	elif by == 2:
		good += 1
	elif by == 1:
		okay += 1
	else:
		$MissedNote.play()
		missed += 1
	
	score += by * combo
	$Score.text = str(score)
	if combo > 0:
		$Combo.text = "Combo: " + str(combo)
		if combo > maxCombo:
			maxCombo = combo
	else:
		$Combo.text = "Combo: 0"
	if combo % 40 == 0 and combo > 0:
		$AnimationPlayer.play("combo")
		$ComboExclamation.text = str(combo) + " in a row!"
		await get_tree().create_timer(2).timeout
		$ComboExclamation.text = ""
	
func reset_combo():
	combo = 0
	$Combo.text = "Combo: 0"

func _on_conductor_finished():
	$Guiding_Lines.hide()
	if score >= 1500:
		$AnimationPlayer.play("nicework")
		$Label.text = "UPGRADE SUCCESSFUL!"
		$UpgradeSuccessful.play()
	if score < 1500:
		$AnimationPlayer.play("nicework")
		$Label.text = "UPGRADE FAILED!"
		$UpgradeFailure.play()



func _on_upgrade_successful_finished():
	get_tree().change_scene_to_file("res://Scenes/bounty_board/bounty_board.tscn")

func _on_upgrade_failure_finished():
	get_tree().change_scene_to_file("res://Scenes/bounty_board/bounty_board.tscn")
