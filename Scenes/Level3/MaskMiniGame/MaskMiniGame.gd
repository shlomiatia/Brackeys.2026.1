extends Node2D

signal mini_game_completed

## Duration (seconds) of the color flash on miss.
@export var flash_duration: float = 1.0
## Duration (seconds) of the fadeout on success.
@export var fadeout_duration: float = 0.5

const MASK_CRACKED := preload("res://Assets/Masked Section/maskCracked.PNG")

@onready var mask: Sprite2D = $Mask
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var camera: ShakingCamera

var _current_tween: Tween
var _flash_tween: Tween
var _is_running: bool = false
var _can_click: bool = true
var _time_since_origin: float = 0.0
var _mask_original_texture: Texture2D

func _ready() -> void:
	_mask_original_texture = mask.texture

func _input(event: InputEvent) -> void:
	if not _is_running or not _can_click:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_click()


func start() -> void:
	if _is_running:
		return
	Global.can_control = false
	_is_running = true
	_can_click = true
	_time_since_origin = 0.0
	modulate = Color.WHITE
	mask.texture = _mask_original_texture
	mask.modulate = Color.WHITE
	# Start with a random rotation outside the success threshold so the player
	# cannot succeed by clicking immediately at the start.
	var start_rot_deg := randf_range(Constants.mask_rotation_threshold_deg + 5.0, Constants.mask_max_rotation_deg)
	mask.rotation = deg_to_rad(start_rot_deg * (1.0 if randf() < 0.5 else -1.0))
	visible = true
	_run_step()


func stop() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_is_running = false


func _on_click() -> void:
	var pos_dist := mask.position.length()
	var rot_dist := absf(rad_to_deg(mask.rotation))
	var success := pos_dist <= Constants.mask_position_threshold and rot_dist <= Constants.mask_rotation_threshold_deg

	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()

	if camera:
		camera.start_screen_shake(1.0, 10.0, 0.1)

	if success:
		stop()
		mask.texture = MASK_CRACKED
		animated_sprite.play("default")
		await animated_sprite.animation_finished
		_flash_tween = create_tween()
		_flash_tween.tween_property(self , "modulate:a", 0.0, fadeout_duration)
		await _flash_tween.finished
		visible = false
		Global.can_control = true
		mini_game_completed.emit()
	else:
		_can_click = false
		mask.modulate = Color.RED
		_flash_tween = create_tween()
		_flash_tween.tween_property(mask, "modulate", Color.WHITE, flash_duration)
		await _flash_tween.finished
		_can_click = true


func _run_step() -> void:
	if not _is_running:
		return

	var duration := randf_range(Constants.mask_min_step_duration, Constants.mask_max_step_duration)
	var force_origin := _time_since_origin >= Constants.mask_max_step_duration

	var target_pos: Vector2
	var target_rot: float

	if force_origin:
		# Mirror current position so the tween passes through origin.
		target_pos = - mask.position
		target_rot = - mask.rotation
		_time_since_origin = 0.0
	else:
		var max_attempts := 10
		for i in range(max_attempts):
			target_pos = Vector2(
				randf_range(-Constants.mask_max_position, Constants.mask_max_position),
				randf_range(-Constants.mask_max_position, Constants.mask_max_position),
			)
			if not _segment_crosses_origin_circle(mask.position, target_pos, Constants.mask_min_distance_from_origin):
				break
		target_rot = deg_to_rad(randf_range(-Constants.mask_max_rotation_deg, Constants.mask_max_rotation_deg))

	_current_tween = create_tween().set_parallel(true)
	_current_tween.tween_property(
		mask, "position", target_pos, duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_current_tween.tween_property(
		mask, "rotation", target_rot, duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_current_tween.finished.connect(_run_step)

	_time_since_origin += duration


func _segment_crosses_origin_circle(a: Vector2, b: Vector2, radius: float) -> bool:
	var d := b - a
	var len_sq := d.dot(d)
	if len_sq == 0.0:
		return a.length() < radius
	var t: float = clamp(-a.dot(d) / len_sq, 0.0, 1.0)
	return (a + t * d).length() < radius
