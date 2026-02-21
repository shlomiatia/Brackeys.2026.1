class_name Slowdown extends Node2D

const RADIUS: float = 32.0
const MAX_SLOW: float = 90.0
const RISE_DURATION: float = 0.5

const REGIONS: Array = [
	Rect2(5, 1, 22, 48),
	Rect2(37, 17, 22, 32),
]

var _player: Player = null
var _chosen_region: Rect2
var _has_risen: bool = false

func _ready() -> void:
	_chosen_region = REGIONS[randi() % 2]
	var sprite := $Sprite2D
	sprite.region_rect = Rect2(_chosen_region.position.x, _chosen_region.position.y, _chosen_region.size.x, 8.0)
	sprite.position.y = -4

func _physics_process(_delta: float) -> void:
	if _player == null:
		return

	var dist = global_position.distance_to(_player.global_position)
	if dist < RADIUS:
		var factor = 1.0 - (dist / RADIUS)
		_player.speed_modifier = - MAX_SLOW * factor
	else:
		_player.speed_modifier = 0.0

func _on_area_body_entered(body: Node2D) -> void:
	if body is Player:
		_player = body
		if not _has_risen:
			_has_risen = true
			_rise()

func _on_area_body_exited(body: Node2D) -> void:
	if body is Player:
		_player.speed_modifier = 0.0
		_player = null

func _rise() -> void:
	var camera := _player.get_node_or_null("ShakingCamera")
	if camera is ShakingCamera:
		camera.start_screen_shake(1.0, 10.0, 0.1)
	var tween := create_tween()
	tween.tween_method(_set_height, 0.0, _chosen_region.size.y, RISE_DURATION) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)

func _set_height(height: float) -> void:
	var sprite := $Sprite2D
	sprite.region_rect = Rect2(_chosen_region.position.x, _chosen_region.position.y, _chosen_region.size.x, height)
	sprite.position.y = - height / 2.0
