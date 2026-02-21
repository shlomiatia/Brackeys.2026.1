extends Node2D

@onready var player: Player = $Objects/Player
@onready var camera: ShakingCamera = $Objects/Player/ShakingCamera
@onready var eye_woman: Sprite2D = $Objects/EyeWoman/EyeWomanSprite
@onready var gaze: Gaze = $Objects/EyeWoman/EyeWomanSprite/Gaze
@onready var bridge: TileMapLayer = $lakeTileMap/BridgeTileMapLayer1
@onready var bridge2: TileMapLayer = $lakeTileMap/BridgeTileMapLayer2
@onready var ground: TileMapLayer = $lakeTileMap/GroundTileMapLayer
@onready var exit_interactable: Interactable = $Objects/Exit/Interactable

var lake_music = load("res://audio/music/creature with eyes music.mp3")
var lake_ambi = load("res://audio/sfx/ambi/sfx_ambi_beauty_lake_loop.mp3")
func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	gaze.all_mirrors_broken.connect(_on_all_mirrors_broken)
	exit_interactable.interacted.connect(_on_exit_interacted)
	AudioManager.play_loop_sfx("lake_ambi", lake_ambi, "Ambi")
	AudioManager.play_music(lake_music)
	await _start_sequence()

func _start_sequence() -> void:
	Global.can_control = false

	await get_tree().create_timer(1.0).timeout

	# Start dialogic conversation (controls already disabled)
	Dialogic.start("level5_start")
	await Dialogic.timeline_ended

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"level5_pan_to_eye_creature":
			# Disable camera _process so it doesn't reset position to Vector2.ZERO
			camera.set_process(false)

			# Move camera to EyeWomanSprite over 0.5s
			var target_offset = eye_woman.global_position - player.global_position
			var tween = create_tween()
			tween.tween_property(camera, "position", target_offset, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			await tween.finished

		"level5_start":
			gaze.visible = true

			await get_tree().create_timer(1.0).timeout

			_move_camera_to_player()

		"level5_last_mirror_break":
			_move_camera_to_player()

		"level5_eye_woman":
			AudioManager.stop_music()
			_reveal_bridge(bridge2)

func _on_all_mirrors_broken() -> void:
	Global.can_control = false
	camera.set_process(false)

	# Move camera to EyeWomanSprite
	var target_offset = eye_woman.global_position - player.global_position
	var tween = create_tween()
	tween.tween_property(camera, "position", target_offset, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

	# Fade in bridge and clear ground collisions underneath
	await _reveal_bridge(bridge)

	await get_tree().create_timer(1.0).timeout

	Dialogic.start("level5_last_mirror_break")
	await Dialogic.timeline_ended

func _reveal_bridge(bridge_layer: TileMapLayer) -> void:
	bridge_layer.visible = true
	bridge_layer.collision_enabled = false
	bridge_layer.modulate = Color(1, 1, 1, 0)
	var fade_tween = create_tween()
	fade_tween.tween_property(bridge_layer, "modulate:a", 1.0, 0.5)
	await fade_tween.finished

	for cell in bridge_layer.get_used_cells():
		var local_pos = bridge_layer.map_to_local(cell)
		var global_pos = bridge_layer.to_global(local_pos)
		var ground_local = ground.to_local(global_pos)
		var ground_cell = ground.local_to_map(ground_local)
		ground.erase_cell(ground_cell)

func _move_camera_to_player() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

	camera.set_process(true)
	Global.can_control = true

func _on_exit_interacted() -> void:
	Global.change_scene("res://Levels/Level6/Level6.tscn")
