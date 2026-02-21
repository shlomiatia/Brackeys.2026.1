extends Node2D

const CLOUD_SPEED := 1.0

@onready var exit_interactable: Interactable = $Objects/Exit/Interactable
@onready var clouds_layer: TileMapLayer = $CloudsTileMapLayer

var music = load("res://audio/music/test music/bella theme v3 progress.mp3")
var _cloud_start_x: float
var _cloud_wrap_width: float

func _ready() -> void:
	_cloud_start_x = clouds_layer.position.x
	var used_rect := clouds_layer.get_used_rect()
	_cloud_wrap_width = used_rect.size.x * clouds_layer.tile_set.tile_size.x
	AudioManager.play_music(music)
	Global.can_control = false
	await get_tree().create_timer(1.0).timeout
	await DialogDisplayer.start("enter_level4")
	exit_interactable.interacted.connect(_on_exit_interacted)

func _process(delta: float) -> void:
	clouds_layer.position.x -= CLOUD_SPEED * delta
	if clouds_layer.position.x < _cloud_start_x - _cloud_wrap_width:
		clouds_layer.position.x += _cloud_wrap_width

func _on_exit_interacted() -> void:
	Global.change_scene("res://Levels/Level4/Level4.tscn")
