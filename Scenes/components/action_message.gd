extends Label


@onready var animation_player = $AnimationPlayer


func _on_animation_over(_name) -> void:
	self.queue_free()


func _ready():
	await get_tree().create_timer(2).timeout

	animation_player.play("fade_out")
	animation_player.animation_finished.connect(_on_animation_over)