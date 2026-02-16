extends Node2D

# Node references
@onready var door: Sprite2D = $Objects/Door
@onready var door_conversation: Conversation = $Objects/Door/Conversation
@onready var ball = $Objects/Ball
@onready var knife: Sprite2D = $Knife

func _ready() -> void:
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
        "knife_picked_up":
            _fade_and_remove(knife)
        "rope_cut":
            ball.cut()

func _fade_and_remove(node: Node2D) -> void:
    var tween = create_tween()
    tween.tween_property(node, "modulate:a", 0.0, 0.5)
    await tween.finished
    node.queue_free()
