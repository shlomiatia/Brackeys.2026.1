class_name Mirror extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Sprite2D/Interactable
@onready var static_body: StaticBody2D = $StaticBody2D

var broken_texture = preload("res://Assets/Eye Section/mirrorBroken.PNG")

# Which frames (directions) this mirror can be rotated to.
# Empty means all frames are supported (original behaviour).
@export var supported_frames: Array[int] = []

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)
	if not supported_frames.is_empty():
		sprite.frame = supported_frames[0]

func _on_interacted() -> void:
	if supported_frames.is_empty():
		sprite.frame = (sprite.frame + 1) % sprite.hframes
		return
	var idx = supported_frames.find(sprite.frame)
	if idx == -1:
		sprite.frame = supported_frames[0]
	else:
		sprite.frame = supported_frames[(idx + 1) % supported_frames.size()]

func break_mirror() -> void:
	sprite.texture = broken_texture
	static_body.collision_layer = 1
