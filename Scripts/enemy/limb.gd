class_name Limb
extends Node2D

### Signals ###
signal on_destroy
signal on_weak(hit_message : String)
signal on_hit(hit_message : String, damage_done : float)

### Exports ###
@export var has_debugs : bool

### Private Variables ###
var _max_health : float
var _current_health : float
var _is_weak : bool
var _display_name : String
var _input_button : MouseButton


### Private Methods ###
func _initialize(new_limb_data : LimbData, shape : CollisionPolygon2D) -> void:
	if new_limb_data == null:
		printerr("[_initialize] No limb data provided")

	# Setup health
	_max_health = new_limb_data.max_health
	_current_health = _max_health
	_is_weak = new_limb_data.is_weak

	# Setup message to send when hit
	_display_name = new_limb_data.display_name

	# Setup input
	_input_button = new_limb_data.click_type

	var click_area = $ClickableArea
	var click_poly = click_area.get_node("Shape")

	# Match the visuals shape as closely as possible
	click_poly.polygon = shape.polygon
	click_poly.position = shape.position
	click_poly.scale = shape.scale
	
	# Set click callbacks
	click_area.input_event.connect(_on_clickable_area_input_event)


func _get_hit_message(damage : float) -> String:
	var hit_message = "You hit %s for %d damage" %[_display_name, damage]
	return hit_message


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
	# Don't take more damage if we are dead
	if not _is_alive():
		return

	# Reduce health
	var damage = amount

	# TODO: May want to change the extra amount
	# taken dynamically somewhere
	# Take double damage if weak
	if _is_weak:
		var message = "You hit a weak point!"
		on_weak.emit(message)
		damage *= 2

	_current_health -= damage

	# DEBUG
	if has_debugs:
		print("[take_damage] %s took %f damage" %[_display_name, damage])

	# Emit that we were hit
	var	hit_display_message = _get_hit_message(damage)
	on_hit.emit(hit_display_message, damage)
	
	# Check if the limb has died
	if not _is_alive():
		destroy()
	


func heal_damage(amount : float) -> void:
	# Increase health
	_current_health += amount
	
	# Don't over heal
	_current_health = min(_current_health, _max_health)

	# DEBUG
	if has_debugs:
		print("[heal_damage] %s healed %f damage" %[_display_name, amount])


func get_current_health() -> float:
	return _current_health


func get_max_health() -> float:
	return _max_health


### Connected Signals ###
func _on_limb_clicked() -> void:
	# No click on dead
	if not _is_alive():
		return

	Global.current_player.take_attack_action(self)


func _on_limb_entered() -> void:
	# No hover on dead
	if not _is_alive():
		return
	
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
