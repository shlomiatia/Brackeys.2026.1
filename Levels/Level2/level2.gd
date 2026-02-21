extends Node2D

@onready var player = $Objects/player
@onready var main_statue = $Objects/MainStatue
@onready var pipe_conversation: Conversation = $Objects/Pipe/Conversation

var level_music = load("res://audio/music/test music/paradise v1 progress.mp3")

func _ready() -> void:
	Global.can_control = false
	AudioManager.play_music(level_music)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	player.z_index = 4
	await _player_fall()
	player.z_index = 0
	await DialogDisplayer.start("level2_enter_clouds")
	Global.can_control = true

func _player_fall() -> void:
	var target_position = player.position
	player.position = Vector2(target_position.x, target_position.y - 200)
	var tween = create_tween()
	tween.tween_property(player, "position", target_position, 3.0)
	await tween.finished

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"statue_correct":
			var tween = create_tween()
			AudioManager.play_sfx(load("res://audio/sfx/sfx_game_lvl2_statue_move.wav"))
			tween.tween_property(main_statue, "position", main_statue.position + Vector2(32, 0), 2.0)
			await tween.finished
			pipe_conversation.interactable_disabled = false
		"level2_pipe_entered":
			Global.change_scene("res://Levels/Level3/Level3.tscn")
