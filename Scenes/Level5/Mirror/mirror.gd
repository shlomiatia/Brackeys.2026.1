class_name Mirror extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Sprite2D/Interactable
@onready var static_body: StaticBody2D = $StaticBody2D

var broken_texture = preload("res://Assets/Eye Section/mirrorBroken.PNG")

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

func _on_interacted() -> void:
	sprite.frame = (sprite.frame + 1) % sprite.hframes

func break_mirror() -> void:
	sprite.texture = broken_texture
	static_body.collision_layer = 1
