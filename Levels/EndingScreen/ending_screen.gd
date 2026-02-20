extends Node2D

@onready var label: Label = $CanvasLayer/Label

func _ready() -> void:
	label.text = Global.ending_name
