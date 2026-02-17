extends Node2D

@export var dialogue_name: String = ""

@onready var conversation: Conversation = $Conversation

func _ready() -> void:
	conversation.dialogue_name = dialogue_name
