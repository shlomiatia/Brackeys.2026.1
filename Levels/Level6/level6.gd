extends Node2D

@onready var player: Player = $Objects/Player
@onready var camera: ShakingCamera = $Objects/Player/ShakingCamera
@onready var death: CharacterBody2D = $Objects/Death
@onready var target_interactable: Interactable = $Objects/Target/Interactable

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	target_interactable.interacted.connect(_on_target_interacted)
	death.caught_player.connect(_on_death_caught_player)
	Global.can_control = false
	await get_tree().create_timer(1.0).timeout
	Dialogic.start("level6_start")
	await Dialogic.timeline_ended

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"level6_yes":
			ending1()
		"level6_no":
			Global.can_control = true
			death.start_chasing(player)

func _on_target_interacted() -> void:
	ending2()

func _on_death_caught_player() -> void:
	ending1()

func ending1() -> void:
	print("ending1")
	pass

func ending2() -> void:
	print("ending2")
	pass
