class_name Level4 extends Node2D

enum Direction {UP, DOWN, LEFT, RIGHT}

const EDGE_LEFT := -198.0
const EDGE_RIGHT := 198.0
const EDGE_TOP := -108.0
const EDGE_BOTTOM := 137.0
const CAMERA_WIDTH := EDGE_RIGHT - EDGE_LEFT
const CAMERA_HEIGHT := EDGE_BOTTOM - EDGE_TOP

@onready var player: Player = $Objects/Player
@onready var fade: Fade = $CanvasLayer/Fade
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

var target_direction: Direction
var current_furniture_index: int = 0
var incorrect_count: int = 0
var correct_count: int = 0
var maze_completed: bool = false

var intro_music = load("res://audio/music/test music/bella theme v2 progress.mp3")

func _ready() -> void:
    pick_direction()
    AudioManager.play_music(intro_music)
    Global.can_control = false
    await get_tree().create_timer(1.0).timeout
    await DialogDisplayer.start("level4_start")

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
    update_hint_color()

func _physics_process(_delta: float) -> void:
    if !Global.can_control or maze_completed:
        return
    update_hint_color()
    if player.position.x < EDGE_LEFT:
        await move_room(Direction.LEFT)
        player.position.x = EDGE_RIGHT
    elif player.position.x > EDGE_RIGHT:
        await move_room(Direction.RIGHT)
        player.position.x = EDGE_LEFT
    elif player.position.y < EDGE_TOP:
        await move_room(Direction.UP)
        player.position.y = EDGE_BOTTOM
    elif player.position.y > EDGE_BOTTOM:
        await move_room(Direction.DOWN)
        player.position.y = EDGE_TOP

func move_room(exited_direction: Direction) -> void:
    Global.can_control = false
    var correct := exited_direction == target_direction
    await fade.fade_out()
    switch_furniture(correct)
    pick_direction(exited_direction)
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
        Global.change_scene("res://Levels/Level5/Level5.tscn")
        return
    elif not correct:
        current_furniture_index = 0
    furniture_layers[current_furniture_index].visible = true
    furniture_layers[current_furniture_index].collision_enabled = true
    floor_layers[current_furniture_index].visible = true
    wall_layers[current_furniture_index].visible = true

func update_hint_color() -> void:
    var distance: float
    var camera_size: float
    match target_direction:
        Direction.UP:
            distance = player.position.y - EDGE_TOP
            camera_size = CAMERA_HEIGHT
        Direction.DOWN:
            distance = EDGE_BOTTOM - player.position.y
            camera_size = CAMERA_HEIGHT
        Direction.LEFT:
            distance = player.position.x - EDGE_LEFT
            camera_size = CAMERA_WIDTH
        Direction.RIGHT:
            distance = EDGE_RIGHT - player.position.x
            camera_size = CAMERA_WIDTH
    var ratio := distance / camera_size
    var c := 1.0 - ratio * Constants.maze_modulate_hint_modifier
    modulate = Color(c, c, c)
    AudioManager.music_player.volume_db = - ratio * Constants.maze_db_hint_modifier
