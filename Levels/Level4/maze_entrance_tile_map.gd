extends Node2D

@onready var exit_interactable: Interactable = $Objects/Exit/Interactable

func _ready() -> void:
	Global.can_control = false
	await get_tree().create_timer(1.0).timeout
	await DialogDisplayer.start("enter_level4")
	exit_interactable.interacted.connect(_on_exit_interacted)

func _on_exit_interacted() -> void:
	Global.change_scene("res://Levels/Level4/Level4.tscn")
