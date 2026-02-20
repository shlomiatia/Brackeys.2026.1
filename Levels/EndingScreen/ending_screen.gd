extends Node2D

@onready var label: Label = $CanvasLayer/Label

func _ready() -> void:
	label.text = Global.ending_name

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		Global.change_scene("res://Levels/Level6/Level6.tscn")
