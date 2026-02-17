class_name Fade extends ColorRect

@export var auto_fade_in: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	show()
	if auto_fade_in:
		fade_in()

func fade_in() -> void:
	animation_player.play("Default")
	await animation_player.animation_finished

func fade_out() -> void:
	animation_player.play_backwards("Default")
	await animation_player.animation_finished
