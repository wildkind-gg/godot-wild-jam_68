class_name Limb
extends Node2D

### Signals ###
signal on_destroy
signal on_hit(hit_message : String)

### Exports ###
@export var has_debugs : bool

### Private Variables ###
var _max_health : float
var _current_health : float
var _display_name : String
var _hit_display_message : String
var _input_button : MouseButton

### Private Methods ###
func _initialize(new_limb_data : LimbData, shape : CollisionPolygon2D) -> void:
	if new_limb_data == null:
		printerr("[_initialize] No limb data provided")

	# Setup health
	_max_health = new_limb_data.max_health
	_current_health = _max_health
	
	# Setup message to send when hit
	_display_name = new_limb_data.display_name
	_hit_display_message = _display_name + ": " + new_limb_data.hit_description

	# Setup input
	_input_button = new_limb_data.click_type

	var click_area = $ClickableArea
	var click_poly = click_area.get_node("Shape")
	click_poly.polygon = shape.polygon
	click_area.input_event.connect(_on_clickable_area_input_event)


func _is_alive() -> bool:
	return _current_health > 0


### Public Methods ###
func create(new_limb_data : LimbData, shape : CollisionPolygon2D) -> void:
	_initialize(new_limb_data, shape)
	
	# DEBUG
	if has_debugs:
		print("[create] Creating new limb : %s" %_display_name)

func destroy() -> void:
	# DEBUG
	if has_debugs:
		print("[destroy] %s was destroied" %_display_name)
	on_destroy.emit()


func take_damage(amount : float) -> void:
	# Reduce health
	_current_health -= amount

	# Check if the limb has died
	if not _is_alive():
		destroy()
		return
	
	# DEBUG
	if has_debugs:
		print("[take_damage] %s took %f damage" %[_display_name, amount])

	# Emit that we were hit
	on_hit.emit(_hit_display_message)


func heal_damage(amount : float) -> void:
	# Increase health
	_current_health += amount
	
	# DEBUG
	if has_debugs:
		print("[heal_damage] %s healed %f damage" %[_display_name, amount])


func get_current_health() -> float:
	return _current_health


func get_max_health() -> float:
	return _max_health


### Connected Signals ###
func _on_limb_clicked() -> void:
	Global.current_player.take_attack_action(self)


func _on_limb_entered() -> void:
	# TODO: Need to figure out a better highlight
	# maybe a shader?
	$Hover.visible = true


func _on_limb_exited() -> void:
	# TODO: Need to figure out a better highlight
	# maybe a shader?
	$Hover.visible = false


func _on_clickable_area_input_event(_viewport, event, _shape_idx) -> void:
	# Make sure we are dealing with a click
	if not (event is InputEventMouseButton):
		return

	# Make sure we are clicking DOWN with the set button
	if event.pressed and event.button_index == _input_button:
		_on_limb_clicked()
