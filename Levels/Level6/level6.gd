extends Node2D

@onready var player: Player = $Objects/Player
@onready var camera: ShakingCamera = $Objects/Player/ShakingCamera
@onready var death: CharacterBody2D = $Objects/Death
@onready var target_area: Area2D = $Objects/Target/Area2D
@onready var intro_area: Area2D = $Objects/Area2D
@onready var run_label: Label = $CanvasLayer/RunLabel

var _intro_triggered: bool = false

var boss_dia_music = load("res://audio/music/deaths anticipation.mp3")
var boss_stinger = load("res://audio/music/boss music stinger.mp3")
var boss_music = load("res://audio/music/deaths embrace.mp3")

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	target_area.body_entered.connect(_on_target_interacted)
	death.caught_player.connect(_on_death_caught_player)
	intro_area.body_entered.connect(_on_intro_area_body_entered)
	AudioManager.play_music(boss_dia_music)
	Global.can_control = false
	await get_tree().create_timer(1.0).timeout
	await DialogDisplayer.start("level6_start")
	Global.can_control = true

func _on_intro_area_body_entered(body: Node2D) -> void:
	if not body is Player or _intro_triggered:
		return
	_intro_triggered = true
	Global.can_control = false
	camera.set_process(false)
	var target_offset = death.global_position - player.global_position
	var tween = create_tween()
	tween.tween_property(camera, "position", target_offset, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	Dialogic.start("level6_choice")
	await Dialogic.timeline_ended

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"level6_yes":
			ending1()
		"level6_no":
			AudioManager.play_music(boss_music)
			await _pan_camera_to_player()
			run_label.visible = true
			death.start_chasing(player)
		"ending_done":
			get_tree().change_scene_to_file("res://Levels/EndingScreen/EndingScreen.tscn")

func _pan_camera_to_player() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	camera.set_process(true)
	Global.can_control = true

func _on_target_interacted(body: Node2D) -> void:
	if not body is Player:
		return
	AudioManager.stop_music()
	ending2()

func _on_death_caught_player() -> void:
	AudioManager.stop_music()
	ending1()

func ending1() -> void:
	Global.can_control = false
	Global.ending_name = "The Acceptance Ending"
	Dialogic.start("level6_ending1")

func ending2() -> void:
	death.chasing = false
	Global.can_control = false
	Global.ending_name = "The Escape Ending"
	Dialogic.start("level6_ending2")
