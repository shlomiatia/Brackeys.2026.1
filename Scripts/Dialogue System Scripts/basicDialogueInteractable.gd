@tool
extends BaseInteractable

## export vars for adjusting per scene
# allows for changing the dialogue. set this to the name of the dialogic timeline
@export var dialogue_name: String = ""
# export vars for the sprite
@export var sprite_texture: Texture2D = null
@export var frame: int = 0
@export var hFrames: int = 1
@export var vFrames: int = 1

## onready vars
@onready var sprite_2d: Sprite2D = $Sprite2D

# triggers base class ready() and connects signals
func _ready() -> void:
	super._ready() # doesn't run the base class ready() without this?
	update_properties() # makes sure the properties update at runtime
	if not Engine.is_editor_hint(): # only does the following in-game
		interacted.connect(_on_interacted)
		Dialogic.timeline_ended.connect(_on_timeline_ended)

# start interaction sequence
func _on_interacted():
	Global.interaction_state = 'basic' # sets interaction state (see comments in Global script)
	Dialogic.start(dialogue_name)
	disable_player()

# allows the player to move/resets interaction state when dialogue ends
func _on_timeline_ended():
	prints("_on_timeline_ended", name)
	if Global.interaction_state == 'basic':
		if is_inside_tree():
			# timeout needed so the interaction state doesn't reset too quickly
			await get_tree().create_timer(0.1).timeout
			Global.interaction_state = '' # resets interaction state
			enable_player()

# calls update_properties continuously in-editor
func _process(_delta: float) -> void:
	super._process(_delta)
	if Engine.is_editor_hint():
		update_properties()

# updates properties
func update_properties() -> void:
	super.update_properties()
	if sprite_2d:
		sprite_2d.texture = sprite_texture
	if sprite_2d.texture:
		sprite_2d.hframes = hFrames
		sprite_2d.vframes = vFrames
		sprite_2d.frame = frame
