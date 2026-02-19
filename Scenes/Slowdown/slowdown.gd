class_name Slowdown extends Node2D

const RADIUS: float = 64.0
const MAX_SLOW: float = 90.0

var _player: Player = null

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(0.5, 0.2, 0.8, 0.3))

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

func _on_area_body_exited(body: Node2D) -> void:
	if body is Player:
		_player.speed_modifier = 0.0
		_player = null
