class_name Ball extends Node2D

@onready var ball: Sprite2D = $Ball
@onready var shadow: Sprite2D = $Shadow
@onready var conversation: Conversation = $Conversation
@onready var shaking_camera: ShakingCamera = $"../../ShakingCamera"
@onready var destroy_floor: AnimatedSprite2D = $DestroyFloor
@onready var hole: Sprite2D = $Hole
@onready var hole_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D

func fall() -> void:
	shaking_camera.start_screen_shake()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	var duration = 0.5
	tween.tween_property(ball, "position:y", -103, duration)
	tween.tween_property(shadow, "scale", Vector2(0.8, 0.8), duration)

	await tween.finished
	conversation.interactable_disabled = false

func cut() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)

	var duration = 0.5
	tween.tween_property(ball, "position:y", 0, duration)
	tween.tween_property(shadow, "scale", Vector2.ONE, duration)

	await tween.finished

	shaking_camera.start_screen_shake()

	ball.visible = false
	shadow.visible = false

	destroy_floor.play()

	hole.visible = true
	hole_collision.disabled = false
	z_index = 0

	conversation.dialogue_name = "level1_hole"
