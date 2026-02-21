extends Node2D

@onready var label: Label = $CanvasLayer/Label

func _ready() -> void:
	label.text = Global.ending_name + "\n\nThanks for playing!"

func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		Global.change_scene("res://Levels/Level6/Level6.tscn")
