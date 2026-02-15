class_name Conversation extends Node2D

@export var dialogue_name: String = ""

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

func _on_interacted() -> void:
	await DialogDisplayer.start(dialogue_name)
