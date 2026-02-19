extends Node2D

@onready var player: Player = $Player
@onready var camera: ShakingCamera = $Player/ShakingCamera
@onready var eye_woman: Sprite2D = $EyeWomanSprite
@onready var gaze: Gaze = $EyeWomanSprite/Gaze
@onready var bridge: TileMapLayer = $BridgeTileMapLayer1
@onready var ground: TileMapLayer = $lakeTileMap/GroundTileMapLayer

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	gaze.all_mirrors_broken.connect(_on_all_mirrors_broken)
	await _start_sequence()

func _start_sequence() -> void:
	Global.can_control = false

	await get_tree().create_timer(1.0).timeout

	# Disable camera _process so it doesn't reset position to Vector2.ZERO
	camera.set_process(false)

	# Move camera to EyeWomanSprite over 0.5s
	var target_offset = eye_woman.global_position - player.global_position
	var tween = create_tween()
	tween.tween_property(camera, "position", target_offset, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

	await get_tree().create_timer(1.0).timeout

	# Start dialogic conversation (controls already disabled)
	Dialogic.start("level5_start")
	await Dialogic.timeline_ended

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"level5_start":
			gaze.visible = true

			await get_tree().create_timer(1.0).timeout

			_move_camera_to_player()

		"level5_last_mirror_break":
			_move_camera_to_player()

func _on_all_mirrors_broken() -> void:
	Global.can_control = false
	camera.set_process(false)

	# Move camera to EyeWomanSprite
	var target_offset = eye_woman.global_position - player.global_position
	var tween = create_tween()
	tween.tween_property(camera, "position", target_offset, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

	# Fade in bridge and disable ground collisions underneath
	bridge.visible = true
	bridge.modulate = Color(1, 1, 1, 0)
	var fade_tween = create_tween()
	fade_tween.tween_property(bridge, "modulate:a", 1.0, 0.5)
	await fade_tween.finished

	# Disable collisions on ground tiles that the bridge covers
	for cell in bridge.get_used_cells():
		var local_pos = bridge.map_to_local(cell)
		var global_pos = bridge.to_global(local_pos)
		var ground_local = ground.to_local(global_pos)
		var ground_cell = ground.local_to_map(ground_local)
		prints("Erasing ground cell at ", ground_cell) # DEBUG
		ground.erase_cell(ground_cell)

	await get_tree().create_timer(1.0).timeout

	Dialogic.start("level5_last_mirror_break")
	await Dialogic.timeline_ended

func _move_camera_to_player() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

	camera.set_process(true)
	Global.can_control = true
