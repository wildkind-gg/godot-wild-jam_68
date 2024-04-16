class_name LimbData
extends Resource

### GLOBAL ###
enum LimbType {
    HEAD,
    TORSO,
    LEFT_ARM,
    RIGHT_ARM,
    LEFT_LEG,
    RIGHT_LEG,
}


### Fields ###
@export var type : LimbType

# Display Values
@export var display_name : String
@export_multiline var hit_description : String = "was hit" ## Used for action message

# Stats
@export var max_health : float

# Interation
@export var click_type : MouseButton = MOUSE_BUTTON_LEFT
@export var area_size : Vector2 = Vector2(2, 2)