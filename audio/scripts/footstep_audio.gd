extends Node

@export var footstep_stream: AudioStream
@export var step_distance := 20.0
@export var volume_db := -6.0

var _last_position := Vector2.ZERO
var _distance := 0.0
var _body: CharacterBody2D

func _ready():
	_body = get_parent() as CharacterBody2D
	_last_position = _body.global_position
	
func _physics_process(delta: float) -> void:
	if _body.velocity.length() < 5:
		_distance = 0
		_last_position = _body.global_position
		return
		
	_distance += _body.global_position.distance_to(_last_position)
	_last_position = _body.global_position
	
	if _distance >= step_distance:
		_distance = 0
		_play_step()
	
func _play_step():
	if footstep_stream == null:
		return
	
	AudioManager.play_sfx(footstep_stream, "Foley", volume_db, 1.0)
