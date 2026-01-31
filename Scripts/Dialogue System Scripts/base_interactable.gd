@tool
extends Node2D
class_name BaseInteractable

## export vars for adjusting per scene
# changes area where the player can interact.
@export var interaction_size: Vector2 = Vector2(1.5,1.5)
@export var interaction_pos: Vector2 = Vector2(0,0)
# changes whether the interaction area can triggered
@export var able_to_interact: bool = true
# adjusts indicator position
@export var indicator_pos: Vector2 = Vector2(0, -27)

## onready vars
@onready var interaction_collision: CollisionShape2D = $interactionArea/CollisionShape2D
@onready var interaction_area: Area2D = $interactionArea
@onready var indicator: Sprite2D = $Indicator
 
var player_in_area: bool = false
signal interacted # emits when the scene is interacted with

# sets indicator visibility to false and sets whether the scene can be interacted with
func _ready() -> void:
	if not Engine.is_editor_hint(): # only do the following if not in editor
		indicator.visible = false
		set_interaction()

# updates properties in-editor and tests whether the player has interacted with the scene
func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): # updates properties
		update_properties()
	if not Engine.is_editor_hint(): # emits 'interacted' when the player interacts with it
		if player_in_area and Input.is_action_just_pressed("interact") and Global.player_can_interact:
			emit_signal("interacted")

# update export vars in editor if they exist
func update_properties() -> void:
	if interaction_collision:
		interaction_collision.scale = interaction_size
		interaction_collision.position = interaction_pos
	if indicator:
		indicator.position = indicator_pos

# function to disallow player from moving/interacting
# to be used when the player interacts with something
func disable_player():
	Global.player_can_interact = false
	Global.player_can_move = false
	
# function to allow player to move/interact
# to be used when the player stops interacting with something
func enable_player(): # allows player to move/interact again
	Global.player_can_interact = true
	Global.player_can_move = true

# makes indicator visible when player is in range
func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		indicator.visible = true
		player_in_area = true

# hides indicator when player goes out of range
func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		indicator.visible = false
		player_in_area = false

# called to change whether scene can be interacted with
func set_interaction():
	interaction_area.monitorable = able_to_interact
	interaction_area.monitoring = able_to_interact
