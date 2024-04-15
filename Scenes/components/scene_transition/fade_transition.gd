extends ColorRect

### Signals ###
signal on_animation_completed

### On Ready ###
@onready var animator : AnimationPlayer = $AnimationPlayer

### Public Methods ###
func play_fade_in() -> void:
	animator.play("fade_in")

func play_fade_out() -> void:
	animator.play("fade_out")

### Signal Emission ###
func _on_animation_player_animation_finished(anim_name : String):
	on_animation_completed.emit()
