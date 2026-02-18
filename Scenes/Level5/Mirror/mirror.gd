class_name Mirror extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Sprite2D/Interactable

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

func _on_interacted() -> void:
	sprite.frame = (sprite.frame + 1) % sprite.hframes
