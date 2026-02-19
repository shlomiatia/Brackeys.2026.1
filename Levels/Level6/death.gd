extends CharacterBody2D

signal caught_player

const SPEED: float = 90.0
const CATCH_DISTANCE: float = 10.0

var chasing: bool = false
var target: Node2D = null

func start_chasing(chase_target: Node2D) -> void:
	target = chase_target
	chasing = true

func _physics_process(_delta: float) -> void:
	if not chasing or target == null:
		return

	var direction = (target.global_position - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()

	if global_position.distance_to(target.global_position) < CATCH_DISTANCE:
		chasing = false
		caught_player.emit()
