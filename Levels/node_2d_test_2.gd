class_name Node2DTest2 extends Node2D

@onready var conversation: Conversation = $Conversation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String):
    if argument == "resumetest4":
        animation_player.play("test4")
