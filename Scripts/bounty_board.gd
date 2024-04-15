extends Node2D

# References
@onready var bounty_item_prefab = preload("res://Scenes/bounty_board/bounty_item.tscn")
@onready var grid_container = $CanvasLayer/Panel/GridContainer

# Constants
const DEFAULT_DISPLAY_NAME : String = "Missing Name"
const DEFAULT_DESCRIPTION : String = "Missing Description"
const DEFAULT_TEXTURE : Texture = preload("res://Resources/_temp_ui_sprites/missing_texture.png")

# TODO: Remove this variable once we have full enemy data structure setup
@export var _temp_enemy_data : Array[EnemyUiData]

# Variables
@export var has_debugs : bool = true
var is_initialzied : bool = false

# Build a bounty item from specific data
func create_bounty_item(ui_data : EnemyUiData):
	# Get values or use defaults if there is no value set
	var display_name : String = ui_data.display_name if ui_data.display_name != null else DEFAULT_DISPLAY_NAME
	var description : String = ui_data.description if ui_data.description != null else DEFAULT_DESCRIPTION
	var texture : Texture = ui_data.texture if ui_data.texture != null else DEFAULT_TEXTURE
	
	# DEBUG
	if has_debugs:
		print("[Creating Item] Display Name: " + display_name)
	
	# Insatantiate bounty item ui
	var new_bounty_item = bounty_item_prefab.instantiate()
	
	# Get child nodes
	var name_text = new_bounty_item.find_child("NameText")
	var description_text = new_bounty_item.find_child("DescriptionText")
	var enemy_texture = new_bounty_item.find_child("EnemyTexture")
	
	# Set values of new ui item
	name_text.text = display_name
	description_text.text = description
	enemy_texture.texture = texture
	
	# Add to grid
	grid_container.add_child(new_bounty_item)


# Build the bounty board from enemy ui data
func initialize_board(enemy_data : Array[EnemyUiData]):
	# Make sure we only initialize once
	if is_initialzied:
		return
	else:
		is_initialzied = true
	
	# DEBUG
	if has_debugs:
		print("[Initializing Board]")
	
	# Create each item from passed data
	for ui_data in enemy_data:
		create_bounty_item(ui_data)


func _process(delta):
	# TODO: This is temporary for testing initialization
	if Input.is_key_pressed(KEY_ENTER):
		initialize_board(_temp_enemy_data)
		
		# DEBUG
		if has_debugs:
			print("Enter Pressed")

