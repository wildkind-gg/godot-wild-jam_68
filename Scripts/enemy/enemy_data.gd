class_name EnemyData
extends Resource

### Fields ###
# Game Data
@export var limbs : Array[LimbData]
@export var visuals : PackedScene
@export var rewards : Array[RewardData]

# Stats
@export var max_speed : float = 10.0
@export var total_heal_actions : int = 5
@export var heal_amount : float
@export var attack_damage : float
## The percentage of total limb health the player needs to deal before enemy is defeated
@export var max_health_percent : float = 60

# UI Data
@export var display_name : String
@export_multiline var description : String
@export var ui_texture : Texture
