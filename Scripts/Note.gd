extends Node2D


var TOP_LEFT_SPAWN = Vector2(randi_range(700,1000), randi_range(200,350))
var BOTTOM_LEFT_SPAWN = Vector2(randi_range(700,1000), randi_range(450,600))
var TOP_RIGHT_SPAWN = Vector2(randi_range(1200,1400), randi_range(200,350))
var BOTTOM_RIGHT_SPAWN = Vector2(randi_range(1200,1400), randi_range(450,600))

var speed = 0
var hit = false

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !hit:
		position.y += speed * delta
		if position.y > 800:
			queue_free()
			get_parent().reset_combo()
	else:
		$Node2D.position.y -= speed * delta

func _initialize(lane):
	if lane == 0:
		position = TOP_LEFT_SPAWN
	elif lane == 1:
		position = BOTTOM_LEFT_SPAWN
	elif lane == 2:
		position = TOP_RIGHT_SPAWN
	elif  lane == 3:
		position = BOTTOM_RIGHT_SPAWN
	else: 
		printerr("Invalid lane set for note: " + str(lane))
		return
	
func _destroy(score):
	$Button.visible = false
	$DestroyTimer.start()
	hit = true


func _on_button_pressed():
	Global.setScore += 1
	Global.setCombo += 1
	$Button.visible = false
	$HitTimer.start()
	hit = true
	$CPUParticles2D.emitting = true
	$CPUParticles2D.modulate = Color("f6d6bd")


func _on_hit_timer_timeout():
	queue_free()


func _on_destroy_timer_timeout():
	queue_free()
