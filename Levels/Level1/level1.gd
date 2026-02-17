extends Node2D

# Node references
@onready var door: Sprite2D = $Objects/Door
@onready var door_conversation: Conversation = $Objects/Door/Conversation
@onready var ball = $Objects/Ball
@onready var knife: Sprite2D = $Knife
@onready var fade: Fade = $CanvasLayer/Fade

var intro_music = load("res://audio/music/test Bella - piano sketch.mp3")

func _ready() -> void:
	play_intro_music()
	# Connect to Dialogic signals
	Dialogic.signal_event.connect(_on_dialogic_signal)

	# Start sequence: disable player movement and show opening dialog
	await _show_start_sequence()

func _show_start_sequence() -> void:
	Global.can_control = false

	# Wait 1 second
	await get_tree().create_timer(1.0).timeout

	# Show opening dialog
	await DialogDisplayer.start("level1_intro")

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"door_interacted":
			ball.fall()
			AudioManager.stop_music()
		"knife_picked_up":
			_fade_and_remove(knife)
		"rope_cut":
			ball.cut()
		"show_scene":
			fade.animation_player.play("Default")

func _fade_and_remove(node: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, 0.5)
	await tween.finished
	node.queue_free()
	
	
# Audio
func play_intro_music():
	AudioManager.play_music(intro_music)
