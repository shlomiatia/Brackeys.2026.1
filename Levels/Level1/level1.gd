extends Node2D

# State tracking
var door_interacted: bool = false

# Node references
@onready var door: Sprite2D = $Objects/Door
@onready var door_conversation: Conversation = $Objects/Door/Conversation
@onready var ball = $Objects/Door/Ball

func _ready() -> void:
    Global.player_can_move = false
    Global.player_can_interact = false

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
    # Update Door conversation based on interaction state
    if not door_interacted:
        door_conversation.dialogue_name = "door_locked_sound"
    else:
        door_conversation.dialogue_name = "door_locked"

func _on_dialogic_signal(argument: String) -> void:
    match argument:
        "solve_puzzle":
            if not door_interacted:
                door_interacted = true
                ball.fall()
                _update_conversation_dialogues()
