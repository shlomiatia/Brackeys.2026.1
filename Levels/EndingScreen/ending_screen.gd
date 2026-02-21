extends Node2D

@onready var label: Label = $CanvasLayer/Label

func _ready() -> void:
	label.text = Global.ending_name + "\n\nThanks for playing!"
	Global.came_from_ending = true

func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		Global.change_scene("res://Levels/TitleScreen/TitleScreen.tscn")
