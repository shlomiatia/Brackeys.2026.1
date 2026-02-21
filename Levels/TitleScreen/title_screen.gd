extends Node2D

var _started := false

func _input(_event: InputEvent) -> void:
	if _started:
		return
	if Input.is_anything_pressed():
		_started = true
		Global.change_scene("res://Levels/Level1/Level1.tscn")
