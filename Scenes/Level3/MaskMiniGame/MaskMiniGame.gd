extends Node2D

## Whether to auto-start on _ready.
@export var auto_start: bool = false
## Duration (seconds) of the color flash on click.
@export var flash_duration: float = 1.0

@onready var mask: Sprite2D = $Mask

var _current_tween: Tween
var _flash_tween: Tween
var _is_running: bool = false
var _time_since_origin: float = 0.0


func _ready() -> void:
    if auto_start:
        start()


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _on_click()


func start() -> void:
    if _is_running:
        return
    _is_running = true
    _time_since_origin = 0.0
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

    mask.modulate = Color.GREEN if success else Color.RED
    _flash_tween = create_tween()
    _flash_tween.tween_property(mask, "modulate", Color.WHITE, flash_duration)


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
        target_pos = Vector2(
            randf_range(-Constants.mask_max_position_x, Constants.mask_max_position_x),
            randf_range(-Constants.mask_max_position_y, Constants.mask_max_position_y),
        )
        target_rot = deg_to_rad(randf_range(-Constants.mask_max_rotation_deg, Constants.mask_max_rotation_deg))

    _current_tween = create_tween().set_parallel(true)
    _current_tween.tween_property(
        mask, "position", target_pos, duration
    ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _current_tween.tween_property(
        mask, "rotation", target_rot, duration
    ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _current_tween.finished.connect(_run_step)

    _time_since_origin += duration
