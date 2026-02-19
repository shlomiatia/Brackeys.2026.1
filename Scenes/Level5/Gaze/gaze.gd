class_name Gaze extends Line2D

@onready var player: Player = get_tree().get_first_node_in_group("player")

# Frame to direction mapping (opposite required for blocking)
# 0: bottom-left, 1: bottom-right, 2: top-right, 3: top-left
const FRAME_DIRECTIONS: Array[Vector2] = [
	Vector2(-1, 1), # 0: bottom-left
	Vector2(1, 1), # 1: bottom-right
	Vector2(1, -1), # 2: top-right
	Vector2(-1, -1), # 3: top-left
]

const BREAK_DURATION: float = 1

var breaking: bool = false
var _flash_tween: Tween

func _process(_delta: float) -> void:
	if !player:
		return

	if breaking:
		return

	var target = to_local(player.global_position) + Vector2(0, -16)
	var from = global_position
	var to = player.global_position + Vector2(0, -16)

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 4

	var result = space_state.intersect_ray(query)

	if result and result.collider is StaticBody2D:
		var mirror = result.collider.get_parent()
		if mirror is Mirror:
			var line_dir = (to - from).normalized()
			var mirror_dir = FRAME_DIRECTIONS[mirror.sprite.frame]
			# Line direction must be opposite to mirror direction
			if _directions_opposite(line_dir, mirror_dir):
				set_point_position(1, to_local(result.position))
				_start_breaking(mirror)
				return

	set_point_position(1, target)

func _start_breaking(mirror: Mirror) -> void:
	breaking = true
	mirror.break_mirror()

	# Flash red then tween back, like the mask in level 3
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	default_color = Color.RED
	_flash_tween = create_tween()
	_flash_tween.tween_property(self , "default_color", Color(1, 1, 1, 0.5019608), BREAK_DURATION)
	await _flash_tween.finished
	breaking = false

func _directions_opposite(line_dir: Vector2, mirror_dir: Vector2) -> bool:
	var opposite = Vector2(-mirror_dir.x, -mirror_dir.y)
	return sign(line_dir.x) == sign(opposite.x) and sign(line_dir.y) == sign(opposite.y)
