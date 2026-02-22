extends Node2D

@onready var label: Label = $CanvasLayer/Label

var _started := false
var title_music = load("res://audio/music/test Bella - piano sketch.mp3")
var start_game_sfx = load("res://audio/sfx/interactions/sfx_ui_interact_1.mp3")
func _ready() -> void:
	AudioManager.play_music(title_music)
	if Global.came_from_ending:
		label.text = "Press any key to try a different ending"

func _input(_event: InputEvent) -> void:
	if _started:
		return
	if Input.is_anything_pressed():
		AudioManager.play_sfx(start_game_sfx)
		AudioManager.stop_music(0.5)
		_started = true
		if Global.came_from_ending:
			Global.came_from_ending = false
			Global.change_scene("res://Levels/Level6/Level6.tscn")
		else:
			Global.change_scene("res://Levels/Level1/Level1.tscn")
