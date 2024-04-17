class_name EnemyData
extends Resource

### Fields ###
# Game Data
@export var limbs : Array[LimbData]
@export var visuals : PackedScene

# Stats
@export var max_speed : float = 10.0
@export var total_heals : float = 3.0
@export var heal_amount : float
@export var attack_damage : float

# UI Data
@export var display_name : String
@export_multiline var description : String
@export var ui_texture : Texture
