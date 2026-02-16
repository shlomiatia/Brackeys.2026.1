extends Node2D

@onready var ball: Sprite2D = $Ball
@onready var shadow: Sprite2D = $Shadow

func fall() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(ball, "position:y", -32, 0.5)
	tween.tween_property(shadow, "scale", Vector2.ONE, 0.5)
