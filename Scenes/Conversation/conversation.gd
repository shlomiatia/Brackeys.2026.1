@tool
class_name Conversation extends Node2D

@export var dialogue_name: String = ""

@export var interactable_size: Vector2 = Vector2(30, 30):
	set(value):
		interactable_size = value
		_update_interactable_size()

@export var indicator_offset: Vector2 = Vector2(0, -21):
	set(value):
		indicator_offset = value
		_update_indicator_offset()

@export var interactable_disabled: bool = false:
	set(value):
		interactable_disabled = value
		_update_interactable_disabled()

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	_update_interactable_size()
	_update_indicator_offset()
	_update_interactable_disabled()
	if !Engine.is_editor_hint():
		interactable.interacted.connect(_on_interacted)

func _on_interacted() -> void:
	await DialogDisplayer.start(dialogue_name)

func _update_interactable_size() -> void:
	if !interactable:
		return
	var collision_shape = interactable.get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape:
		collision_shape.shape.size = interactable_size

func _update_indicator_offset() -> void:
	if !interactable:
		return
	var indicator = interactable.get_node_or_null("Indicator")
	if indicator:
		indicator.position = indicator_offset

func _update_interactable_disabled() -> void:
	if !interactable:
		return
	var collision_shape = interactable.get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.disabled = interactable_disabled
