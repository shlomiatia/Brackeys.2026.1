extends Node2D

# Node references
@onready var door: Sprite2D = $Objects/Door
@onready var door_conversation: Conversation = $Objects/Door/Conversation
@onready var ball = $Objects/Ball
@onready var rope: Sprite2D = $Rope
@onready var rope_conversation: Conversation = $Rope/Conversation
@onready var knife: Sprite2D = $Knife
@onready var fade: Fade = $CanvasLayer/Fade
@onready var instruction_label: Label = $CanvasLayer/InstructionLabel

var intro_music = load("res://audio/music/test music/bella theme v3 progress.mp3")
var ball_appear_sfx = load("res://audio/sfx/sfx_cutscene_lvl1_ball_appears.mp3")
var ball_crash = load("res://audio/sfx/sfx_cutscene_lvl1_ball_crash.mp3")
var hole_ambi = load("res://audio/sfx/ambi/sfx_ambi_ground_ambi.wav")

enum _InstructionPhase {NONE, MOVE, INTERACT}
var _instruction_phase: _InstructionPhase = _InstructionPhase.NONE

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

	# Show movement hint now that the player has control
	instruction_label.text = "WASD to move"
	instruction_label.visible = true
	_instruction_phase = _InstructionPhase.MOVE

func _input(event: InputEvent) -> void:
	match _instruction_phase:
		_InstructionPhase.MOVE:
			if event.is_action_pressed("move_left") or event.is_action_pressed("move_right") \
					or event.is_action_pressed("move_up") or event.is_action_pressed("move_down"):
				_instruction_phase = _InstructionPhase.NONE
				await get_tree().create_timer(1.0).timeout
				instruction_label.text = "E to interact"
				_instruction_phase = _InstructionPhase.INTERACT
		_InstructionPhase.INTERACT:
			if event.is_action_pressed("interact"):
				_instruction_phase = _InstructionPhase.NONE
				var tween = create_tween()
				tween.tween_property(instruction_label, "modulate:a", 0.0, 0.5)
				await tween.finished
				instruction_label.visible = false

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"door_interacted":
			ball.fall()
			AudioManager.play_sfx(ball_crash)
			AudioManager.stop_music()
		"knife_picked_up":
			_fade_and_remove(knife)
		"rope_cut":
			AudioManager.play_sfx(ball_appear_sfx, "SFX", -12)
			AudioManager.play_loop_sfx("hole_ambience", hole_ambi, "Ambi", -20)
			ball.cut()
			rope_conversation.interactable_disabled = true
			var rope_tween = create_tween()
			rope_tween.set_trans(Tween.TRANS_SINE)
			rope_tween.set_ease(Tween.EASE_IN)
			rope_tween.tween_property(rope, "position:y", -800, 0.8)
		"show_scene":
			fade.fade_in()
		"jump_in_hole":
			Global.change_scene("res://Levels/Level2/Level2.tscn")

func _fade_and_remove(node: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, 0.5)
	await tween.finished
	node.queue_free()


# Audio
func play_intro_music():
	AudioManager.play_music(intro_music)
