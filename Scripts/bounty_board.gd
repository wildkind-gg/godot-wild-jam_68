extends Node2D

### On Ready Variables ###
@onready var bounty_item_prefab = preload("res://Scenes/bounty_board/bounty_item.tscn")
@onready var grid_container = $Board/Panel/GridContainer
@onready var scene_transition = $Loading/SceneTransition
@onready var fade_transition = $Loading/SceneTransition/FadeTransition

### Constants ###
const DEFAULT_DISPLAY_NAME : String = "Missing Name"
const DEFAULT_DESCRIPTION : String = "Missing Description"
const DEFAULT_TEXTURE : Texture = preload("res://Resources/_temp_ui_sprites/missing_texture.png")

### Editor Parameters ###
# TODO: Remove this variable once we have full enemy data structure setup
@export var enemy_data : Array[EnemyData]
@export var has_debugs : bool

### Private Variables ###
var _is_initialzied : bool = false

### Private Methods ###
func _on_item_clicked(item_enemy : EnemyData):
	Global.current_enemy = item_enemy
	scene_transition.start_transition()
	SceneChange.play()


# Build a bounty item from specific data
func _create_bounty_item(new_enemy_data : EnemyData) -> void:
	# Get values or use defaults if there is no value set
	var display_name : String = new_enemy_data.display_name if new_enemy_data.display_name != null else DEFAULT_DISPLAY_NAME
	var description : String = new_enemy_data.description if new_enemy_data.description != null else DEFAULT_DESCRIPTION
	var texture : Texture = new_enemy_data.ui_texture if new_enemy_data.ui_texture != null else DEFAULT_TEXTURE
	
	# DEBUG
	if has_debugs:
		print("[_create_bounty_item] Display Name: %s" %display_name)
	
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
	new_item_btn.button_up.connect(func():
		_on_item_clicked(new_enemy_data)
	)
	
	# Add to grid
	grid_container.add_child(new_bounty_item)


### Public Methods ###
# Build the bounty board from enemy ui data
func initialize_board(new_enemy_data : Array[EnemyData]) -> void:
	# Make sure we only initialize once
	if _is_initialzied:
		return
	else:
		_is_initialzied = true
	
	# DEBUG
	if has_debugs:
		print("[initialize_board] Initializing Board")
	
	# Create each item from passed data
	for data in new_enemy_data:
		_create_bounty_item(data)


func on_scene_loaded():
	# Fade in animation
	fade_transition.play_fade_in()
	
	# TODO: This is temporary for testing initialization
	# need to implement propper enemy data later
	initialize_board(enemy_data)


### Built in Methods ###
func _ready():
	on_scene_loaded()
	MenuMusic.volume_db = 0.0
	BattleMusic.volume_db = -80
	
	if !MenuMusic.playing:
		MenuMusic.play()
	if !BattleMusic.playing:
		BattleMusic.play()

func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://Scenes/menus/main_menu.tscn")

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/menus/main_menu.tscn")
