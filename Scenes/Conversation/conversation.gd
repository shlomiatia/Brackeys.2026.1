class_name Conversation extends Node2D

@export var dialogue_name: String = ""

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

func _on_interacted() -> void:
	Global.player_can_move = false
	Global.player_can_interact = false

	Dialogic.start(dialogue_name)
	await Dialogic.timeline_ended
	
	Global.player_can_move = true
	Global.player_can_interact = true
