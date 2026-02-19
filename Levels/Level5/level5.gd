extends Node2D

@onready var player: Player = $Player
@onready var camera: ShakingCamera = $Player/ShakingCamera
@onready var eye_woman: Sprite2D = $EyeWomanSprite
@onready var gaze: Gaze = $EyeWomanSprite/Gaze

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
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

			# Move camera back to player over 0.5s
			var tween = create_tween()
			tween.tween_property(camera, "position", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			await tween.finished

			# Re-enable camera shake processing
			camera.set_process(true)
			Global.can_control = true
