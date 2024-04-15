extends Node2D

### On Ready Variables ###
@onready var bounty_item_prefab = preload("res://Scenes/bounty_board/bounty_item.tscn")
@onready var grid_container = $Board/Panel/GridContainer
@onready var scene_transition = $Loading/SceneTransition
@onready var fade_transition = $Loading/FadeTransition

### Constants ###
const DEFAULT_DISPLAY_NAME : String = "Missing Name"
const DEFAULT_DESCRIPTION : String = "Missing Description"
const DEFAULT_TEXTURE : Texture = preload("res://Resources/_temp_ui_sprites/missing_texture.png")

### Editor Parameters ###
# TODO: Remove this variable once we have full enemy data structure setup
@export var _temp_enemy_data : Array[EnemyUiData]
@export var has_debugs : bool = true

### Private Variables ###
var _is_initialzied : bool = false

### Private Methods ###
func _on_item_clicked():
	print("Clicked")
	scene_transition.start_transition()

# Build a bounty item from specific data
func _create_bounty_item(ui_data : EnemyUiData) -> void:
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
	
	# Connect click event to scene transition
	var new_item_btn = new_bounty_item.find_child("Button")
	new_item_btn.button_up.connect(_on_item_clicked)
	
	# Add to grid
	grid_container.add_child(new_bounty_item)


### Public Methods ###
# Build the bounty board from enemy ui data
func initialize_board(enemy_data : Array[EnemyUiData]) -> void:
	# Make sure we only initialize once
	if _is_initialzied:
		return
	else:
		_is_initialzied = true
	
	# DEBUG
	if has_debugs:
		print("[Initializing Board]")
	
	# Create each item from passed data
	for ui_data in enemy_data:
		_create_bounty_item(ui_data)

func on_scene_loaded():
	# Fade in animation
	fade_transition.play_fade_in()
	
	# TODO: This is temporary for testing initialization
	# need to implement propper enemy data later
	initialize_board(_temp_enemy_data)


### Built in Methods ###
func _ready():
	on_scene_loaded()
