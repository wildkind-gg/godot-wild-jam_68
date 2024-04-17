class_name LimbData
extends Resource


### Fields ###
@export var type : Global.LimbType

# Display Values
@export var display_name : String
@export_multiline var hit_description : String = "was hit" ## Used for action message

# Stats
@export var max_health : float

# Interation
@export var click_type : MouseButton = MOUSE_BUTTON_LEFT
