extends Node
var music_a = load("res://audio/music/test music 1.mp3")
var music_b = load("res://audio/music/test music 2.mp3")
var sfx_a = load("res://audio/sfx/test sfx.wav")

func _on_pressed() -> void:
	AudioManager.play_music(music_a)
	pass # Replace with function body.


func _on_play_music_2_pressed() -> void:
	AudioManager.play_music(music_b)
	pass # Replace with function body.


func _on_stop_pressed() -> void:
	AudioManager.stop_music()
	pass # Replace with function body.


func _on_duck_pressed() -> void:
	AudioManager.duck_music()
	pass # Replace with function body.


func _on_restore_pressed() -> void:
	AudioManager.restore_music()
	pass # Replace with function body.


func _on_play_sfx_pressed() -> void:
	AudioManager.play_sfx(sfx_a)
	pass # Replace with function body.
