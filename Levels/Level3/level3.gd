extends Node2D

@onready var player = $Objects/player
@onready var mask_mini_game = $CanvasLayer/MaskMiniGame
@onready var small_creature1 = $Objects/SmallMaskedCreature1
@onready var small_creature2 = $Objects/SmallMaskedCreature2
@onready var small_creature3 = $Objects/SmallMaskedCreature3
@onready var exit_interactable: Interactable = $Objects/Exit/Interactable
@onready var exit_sewer_closed: Sprite2D = $SewerTileMaps/ExitSewerClosed
@onready var exit_sewer_open: Sprite2D = $SewerTileMaps/ExitSewerOpen

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	exit_interactable.interacted.connect(_on_exit_interacted)
	exit_interactable.remove_from_group("interactables")


func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"fight_small_masked_creature1":
			await _fight_creature(small_creature1)
		"fight_small_masked_creature2":
			await _fight_creature(small_creature2)
		"fight_small_masked_creature3":
			await _fight_creature(small_creature3)
		"level3_door_opened":
			exit_interactable.add_to_group("interactables")
			exit_sewer_closed.visible = false
			exit_sewer_open.visible = true


func _on_exit_interacted() -> void:
	Global.change_scene("res://Levels/Level4/maze_entrance_tile_map.tscn")


func _fight_creature(creature: Node2D) -> void:
	Global.can_control = false
	await get_tree().create_timer(1.0).timeout
	mask_mini_game.start()
	await mask_mini_game.mini_game_completed
	var tween = create_tween()
	tween.tween_property(creature, "modulate:a", 0.0, 0.5)
	await tween.finished
	creature.queue_free()
