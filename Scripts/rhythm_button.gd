extends AnimatedSprite2D

var perfect = false
var good = false
var okay = false
var current_note = null

@export var input = ""


func _unhandled_input(event):
	if event.is_action(input):
		if event.is_action_pressed(input, false):
			if current_note != null:
				if perfect:
					get_parent()._increment_score(3)
					current_note.queue_free()
				elif good:
					get_parent()._increment_score(2)
					current_note.queue_free()
				elif okay:
					get_parent()._increment_score(1)
					current_note.queue_free()
				_reset()
			else:
				get_parent()._increment_score(0)
		if event.is_action_pressed(input):
			frame = 1
		elif event.is_action_released(input):
			$Pushtimer.start()
					

func _on_perfect_area_area_entered(area):
	if area.is_in_group("note"):
		perfect = true


func _on_perfect_area_area_exited(area):
	if area.is_in_group("note"):
		perfect = false


func _on_good_area_area_entered(area):
	if area.is_in_group("note"):
		good = true


func _on_good_area_area_exited(area):
	if area.is_in_group("note"):
		good = false


func _on_okay_area_area_entered(area):
	if area.is_in_group("note"):
		okay = true
		current_note = area


func _on_okay_area_area_exited(area):
	if area.is_in_group("note"):
		okay = false
		current_note = null

func _on_pushtimer_timeout():
	frame = 0

func _reset():
	current_note = null
	perfect = false
	good = false
	okay = false
