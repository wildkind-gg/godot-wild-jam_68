extends Area2D

const TARGET_Y = 600
const SPAWN_Y = -16
const DIST_TO_TARGET = TARGET_Y - SPAWN_Y

const LEFT_LANE_SPAWN = Vector2(450, SPAWN_Y)
const CENTER_LANE_SPAWN = Vector2(570, SPAWN_Y)
const RIGHT_LANE_SPAWN = Vector2(690, SPAWN_Y)

var speed = 0
var hit = false

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !hit:
		position.y += speed * delta
		if position.y > 700:
			queue_free()
			get_parent().reset_combo()
	else:
		$Node2D.position.y -= speed * delta

func _initialize(lane):
	if lane == 0:
		$AnimatedSprite2D.frame = 0
		position = LEFT_LANE_SPAWN
	elif lane == 1:
		$AnimatedSprite2D.frame = 1
		position = CENTER_LANE_SPAWN
	elif lane == 2:
		$AnimatedSprite2D.frame = 2
		position = RIGHT_LANE_SPAWN
	else: 
		printerr("Invalid lane set for note: " + str(lane))
		return
	
	speed = DIST_TO_TARGET / 2.0
	
func _destroy(score):
	$AnimatedSprite2D.visible = false
	$DestroyTimer.start()
	hit = true
	if score == 3:
		$CPUParticles2D.emitting = true
		$CPUParticles2D.modulate = Color("f6d6bd")
		$Node2D/Label.text = "GREAT"
		$Node2D/Label.modulate = Color("f6d6bd")
	elif score == 2:
		$CPUParticles2D.emitting = true
		$CPUParticles2D.modulate = Color("c3a38a")
		$Node2D/Label.text = "GOOD"
		$Node2D/Label.modulate = Color("c3a38a")
	elif score == 1:
		$CPUParticles2D.emitting = true
		$CPUParticles2D.modulate = Color("997577")
		$Node2D/Label.text = "OKAY"
		$Node2D/Label.modulate = Color("997577")
		
func _on_timer_timeout():
	queue_free()
