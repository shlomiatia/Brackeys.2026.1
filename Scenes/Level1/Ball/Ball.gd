extends Node2D

@onready var ball: Sprite2D = $Ball
@onready var shadow: Sprite2D = $Shadow
@onready var conversation: Conversation = $Shadow/Conversation

func fall() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	var duration = 0.5
	tween.tween_property(ball, "position:y", -32, duration)
	tween.tween_property(shadow, "scale", Vector2.ONE, duration)

	await tween.finished
	conversation.interactable_disabled = false
