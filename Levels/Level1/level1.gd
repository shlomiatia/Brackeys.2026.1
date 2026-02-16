extends Node2D

# State tracking
var door_puzzle_solved: bool = false

# Node references
@onready var door: Sprite2D = $Objects/Door
@onready var real_door: Sprite2D = $Objects/RealDoor
@onready var door_conversation: Conversation = $Objects/Door/Conversation
@onready var real_door_conversation: Conversation = $Objects/RealDoor/Conversation

func _ready() -> void:
	# Connect to Dialogic signals
	Dialogic.signal_event.connect(_on_dialogic_signal)

	# Start sequence: disable player movement and show opening dialog
	await _show_start_sequence()

	# Set initial dialogue names for conversations
	_update_conversation_dialogues()

func _show_start_sequence() -> void:
	# Wait 1 second
	await get_tree().create_timer(1.0).timeout

	# Show opening dialog
	await DialogDisplayer.start("start_dialog")

func _update_conversation_dialogues() -> void:
	# Update Door conversation based on puzzle state
	if not door_puzzle_solved:
		door_conversation.dialogue_name = "door_locked_sound"
	else:
		door_conversation.dialogue_name = "door_locked"

	# Update RealDoor conversation based on puzzle state
	if not door_puzzle_solved:
		real_door_conversation.dialogue_name = "coin_dialog"
	else:
		real_door_conversation.dialogue_name = "solved_dialog"

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"solve_puzzle":
			_solve_door_puzzle()

func _solve_door_puzzle() -> void:
	# Mark puzzle as solved
	door_puzzle_solved = true

	# Change RealDoor texture to tax.png
	var tax_texture = load("res://Assets/tax.png")
	real_door.texture = tax_texture

	# Update the conversation dialogues for new state
	_update_conversation_dialogues()
