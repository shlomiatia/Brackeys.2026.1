extends Node2D

@onready var player = $Objects/player

func _ready() -> void:
	Global.can_control = false
	await _player_fall()
	Global.can_control = true

func _player_fall() -> void:
	var target_position = player.position
	player.position = Vector2(target_position.x, target_position.y - 200)
	var tween = create_tween()
	tween.tween_property(player, "position", target_position, 3.0)
	await tween.finished
