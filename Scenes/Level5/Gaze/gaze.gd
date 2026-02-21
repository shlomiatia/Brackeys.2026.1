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
const LERP_SPEED: float = 5.0
const MAX_REFLECTIONS: int = 8

signal all_mirrors_broken

var breaking: bool = false
var _flash_tween: Tween
var _mirrors_broken: int = 0

func _process(delta: float) -> void:
	if !player or breaking or !visible:
		return

	var target = to_local(player.global_position) + Vector2(0, -16)
	var from = global_position
	var to = player.global_position + Vector2(0, -16)
	var line_dir = (to - from).normalized()
	var diagonal = get_viewport_rect().size.length()

	var point_index = 1
	var mirrors_in_chain: Array[Mirror] = []
	var exclude: Array[RID] = []
	var is_first_segment = true

	for _i in MAX_REFLECTIONS:
		var seg = _check_mirror_hit(from, to, line_dir, exclude)

		if seg.type == "break":
			_set_or_add_point(point_index, to_local(seg.hit_pos))
			_remove_extra_points(point_index + 1)
			mirrors_in_chain.append(seg.mirror)
			_start_breaking(mirrors_in_chain)
			return

		if seg.type == "reflect":
			_set_or_add_point(point_index, to_local(seg.hit_pos))
			mirrors_in_chain.append(seg.mirror)
			exclude.append(seg.collider.get_rid())
			from = seg.hit_pos
			to = seg.hit_pos + seg.reflected_dir * diagonal
			line_dir = seg.reflected_dir
			point_index += 1
			is_first_segment = false
			continue

		# "none" or "behind": end of chain
		if is_first_segment:
			_remove_extra_points(2)
			var current = get_point_position(1)
			set_point_position(1, current.lerp(target, delta * LERP_SPEED))
		else:
			_set_or_add_point(point_index, to_local(to))
			_remove_extra_points(point_index + 1)
		return

	# Safety fallback if reflection limit is reached
	_set_or_add_point(point_index, to_local(to))
	_remove_extra_points(point_index + 1)

# Casts a ray and returns what kind of mirror hit occurred.
# type: "break" | "reflect" | "behind" | "none"
func _check_mirror_hit(from: Vector2, to: Vector2, line_dir: Vector2, exclude: Array[RID] = []) -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 4
	query.exclude = exclude
	var result = space_state.intersect_ray(query)

	if result and result.collider is StaticBody2D:
		var mirror = result.collider.get_parent()
		if mirror is Mirror:
			var mirror_dir = FRAME_DIRECTIONS[mirror.sprite.frame]
			if _directions_opposite(line_dir, mirror_dir):
				return {type = "break", mirror = mirror, collider = result.collider, hit_pos = result.position}
			if sign(line_dir.x) == sign(mirror_dir.x) and sign(line_dir.y) == sign(mirror_dir.y):
				return {type = "behind"}
			var reflected_dir = Vector2(
				abs(line_dir.x) * sign(mirror_dir.x),
				abs(line_dir.y) * sign(mirror_dir.y)
			).normalized()
			return {type = "reflect", mirror = mirror, collider = result.collider, hit_pos = result.position, reflected_dir = reflected_dir}

	return {type = "none"}

func _set_or_add_point(index: int, pos: Vector2) -> void:
	if get_point_count() <= index:
		add_point(pos)
	else:
		set_point_position(index, pos)

func _remove_extra_points(keep_count: int) -> void:
	while get_point_count() > keep_count:
		remove_point(get_point_count() - 1)

func _start_breaking(mirrors: Array[Mirror]) -> void:
	Global.can_control = false
	breaking = true
	for mirror in mirrors:
		mirror.break_mirror()

	# Flash red then tween back, like the mask in level 3
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	default_color = Color.RED
	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "default_color", Color(1, 1, 1, 0.5019608), BREAK_DURATION)
	await _flash_tween.finished
	Global.can_control = true
	_mirrors_broken += mirrors.size()
	if _mirrors_broken == 1:
		await DialogDisplayer.start("level5_first_mirror_break")
	elif _mirrors_broken < 4:
		await DialogDisplayer.start("level5_mirror_break")
	else:
		hide()
		all_mirrors_broken.emit()
	breaking = false

func _directions_opposite(line_dir: Vector2, mirror_dir: Vector2) -> bool:
	var opposite = Vector2(-mirror_dir.x, -mirror_dir.y)
	return sign(line_dir.x) == sign(opposite.x) and sign(line_dir.y) == sign(opposite.y)
