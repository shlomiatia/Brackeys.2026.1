class_name Level4 extends Node2D

enum Direction {UP, DOWN, LEFT, RIGHT}

const CLOUD_SPEED := 1.0
const EDGE_LEFT := -198.0
const EDGE_RIGHT := 198.0
const EDGE_TOP := -108.0
const EDGE_BOTTOM := 137.0
const CAMERA_WIDTH := EDGE_RIGHT - EDGE_LEFT
const CAMERA_HEIGHT := EDGE_BOTTOM - EDGE_TOP

@onready var clouds_layer: TileMapLayer = $CloudsTileMapLayer
@onready var player: Player = $Objects/Player
@onready var fade: Fade = $CanvasLayer/Fade
@onready var camera: ShakingCamera = $ShakingCamera
@onready var red_flash: ColorRect = $CanvasLayer/RedFlash
@onready var furniture_layers: Array[TileMapLayer] = [
	$Objects/FurnitureTileMapLayer1,
	$Objects/FurnitureTileMapLayer2,
	$Objects/FurnitureTileMapLayer3,
	$Objects/FurnitureTileMapLayer4,
]
@onready var floor_layers: Array[TileMapLayer] = [
	$FloorTileMapLayer1,
	$FloorTileMapLayer2,
	$FloorTileMapLayer3,
	$FloorTileMapLayer4,
]
@onready var wall_layers: Array[TileMapLayer] = [
	$WallsTileMapLayer1,
	$WallsTileMapLayer2,
	$WallsTileMapLayer3,
	$WallsTileMapLayer4,
]

var _cloud_start_x: float
var _cloud_wrap_width: float

var target_direction: Direction
var current_furniture_index: int = 0
var incorrect_count: int = 0
var correct_count: int = 0
var maze_completed: bool = false

var intro_music = load("res://audio/music/test music/bella theme v3 progress.mp3")

func _ready() -> void:
	_cloud_start_x = clouds_layer.position.x
	var used_rect := clouds_layer.get_used_rect()
	_cloud_wrap_width = used_rect.size.x * clouds_layer.tile_set.tile_size.x
	pick_direction(Direction.UP)
	AudioManager.play_music(intro_music)
	Global.can_control = false
	await get_tree().create_timer(1.0).timeout
	await DialogDisplayer.start("level4_start")

func _process(delta: float) -> void:
	clouds_layer.position.x -= CLOUD_SPEED * delta
	if clouds_layer.position.x < _cloud_start_x - _cloud_wrap_width:
		clouds_layer.position.x += _cloud_wrap_width

func opposite(dir: Direction) -> Direction:
	match dir:
		Direction.UP: return Direction.DOWN
		Direction.DOWN: return Direction.UP
		Direction.LEFT: return Direction.RIGHT
		_: return Direction.LEFT

func pick_direction(exited_direction := -1) -> void:
	var new_direction := randi() % 4
	while exited_direction != -1 and new_direction == opposite(exited_direction as Direction):
		new_direction = randi() % 4
	target_direction = new_direction as Direction
	# update_hint_color()

func _physics_process(_delta: float) -> void:
	if maze_completed:
		return
	update_hint_color()
	if !Global.can_control:
		return
	if player.position.x < EDGE_LEFT:
		await move_room(Direction.LEFT)
	elif player.position.x > EDGE_RIGHT:
		await move_room(Direction.RIGHT)
	elif player.position.y < EDGE_TOP:
		await move_room(Direction.UP)
	elif player.position.y > EDGE_BOTTOM:
		await move_room(Direction.DOWN)

func move_room(exited_direction: Direction) -> void:
	Global.can_control = false
	var correct := exited_direction == target_direction
	await fade.fade_out()
	switch_furniture(correct)
	pick_direction(exited_direction)
	match exited_direction:
		Direction.LEFT: player.position.x = EDGE_RIGHT
		Direction.RIGHT: player.position.x = EDGE_LEFT
		Direction.UP: player.position.y = EDGE_BOTTOM
		Direction.DOWN: player.position.y = EDGE_TOP
	enter_room(exited_direction)
	if not correct:
		camera.start_screen_shake(1.0, 10.0, 0.05)
		flash_red()
	await fade.fade_in()
	if correct:
		correct_count += 1
		if correct_count == 1:
			await DialogDisplayer.start("level4_correct1")
	else:
		incorrect_count += 1
		if incorrect_count == 1:
			await DialogDisplayer.start("level4_incorrect1")
		elif incorrect_count == 3:
			await DialogDisplayer.start("level4_incorrect3")
	Global.can_control = true

func switch_furniture(correct: bool) -> void:
	furniture_layers[current_furniture_index].visible = false
	furniture_layers[current_furniture_index].collision_enabled = false
	floor_layers[current_furniture_index].visible = false
	wall_layers[current_furniture_index].visible = false
	if correct and current_furniture_index < furniture_layers.size() - 1:
		current_furniture_index += 1
	elif correct and current_furniture_index == furniture_layers.size() - 1:
		# Completed the final room
		maze_completed = true
		get_tree().change_scene_to_file("res://Levels/Level5/Level5.tscn")
		return
	elif not correct:
		current_furniture_index = 0
	furniture_layers[current_furniture_index].visible = true
	furniture_layers[current_furniture_index].collision_enabled = true
	floor_layers[current_furniture_index].visible = true
	wall_layers[current_furniture_index].visible = true

func enter_room(exited_direction: Direction) -> void:
	var dir_name: String
	var move_offset: Vector2
	match exited_direction:
		Direction.LEFT:
			dir_name = "L"
			move_offset = Vector2(-16, 0)
		Direction.RIGHT:
			dir_name = "R"
			move_offset = Vector2(16, 0)
		Direction.UP:
			dir_name = "Bck"
			move_offset = Vector2(0, -32)
		Direction.DOWN:
			dir_name = "Fr"
			move_offset = Vector2(0, 32)
	player.current_direction = dir_name
	player.set_physics_process(false)
	player.animated_sprite.play("walk" + dir_name)
	var tween := create_tween()
	tween.tween_property(player, "position", player.position + move_offset, 0.6)
	await tween.finished
	player.set_physics_process(true)

func flash_red() -> void:
	red_flash.color.a = 0.5
	var tween := create_tween()
	tween.tween_property(red_flash, "color:a", 0.0, 0.8)

func update_hint_color() -> void:
	var target_pos: Vector2
	match target_direction:
		Direction.UP: target_pos = Vector2(0, EDGE_TOP)
		Direction.DOWN: target_pos = Vector2(0, EDGE_BOTTOM)
		Direction.LEFT: target_pos = Vector2(EDGE_LEFT, -24.0)
		Direction.RIGHT: target_pos = Vector2(EDGE_RIGHT, -24.0)
	var max_dist := Vector2(CAMERA_WIDTH / 2.0, CAMERA_HEIGHT / 4.0).length()
	var ratio := minf(1.0, player.position.distance_to(target_pos) / max_dist)
	var c := 1.0 - ratio * Constants.maze_modulate_hint_modifier
	var hint_color := Color(c, c, c)
	modulate = hint_color
	(clouds_layer.material as ShaderMaterial).set_shader_parameter("modulate_color", hint_color)
	AudioManager.music_player.volume_db = - ratio * Constants.maze_db_hint_modifier
