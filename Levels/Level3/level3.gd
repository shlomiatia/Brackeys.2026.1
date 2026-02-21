extends Node2D

@onready var player = $Objects/player
@onready var fade: Fade = $CanvasLayer/Fade
@onready var mask_mini_game = $CanvasLayer/MaskMiniGame
@onready var small_creature1 = $Objects/SmallMaskedCreature1
@onready var small_creature2 = $Objects/SmallMaskedCreature2
@onready var small_creature3 = $Objects/SmallMaskedCreature3
@onready var exit_interactable: Interactable = $Objects/Exit/Interactable
@onready var exit_sewer_closed: Sprite2D = $SewerTileMaps/ExitSewerClosed
@onready var exit_sewer_open: Sprite2D = $SewerTileMaps/ExitSewerOpen

@export var water_light_color: Color = Color.WHITE
@export var water_light_energy: float = 1.5
@export var water_light_texture_scale: float = 1.0

func _ready() -> void:
	Global.can_control = false
	Dialogic.signal_event.connect(_on_dialogic_signal)
	AudioManager.play_music(load("res://audio/music/music_dark and cold.mp3"))
	AudioManager.play_loop_sfx("sewer", load("res://audio/sfx/ambi/sfx_sewer_ambi_loop.mp3"), "Ambi")
	exit_interactable.interacted.connect(_on_exit_interacted)
	exit_interactable.remove_from_group("interactables")
	_setup_water_lights()
	await fade.fade_in()
	await DialogDisplayer.start("level3_enter_sewers")


func _setup_water_lights() -> void:
	var light_coords := [Vector2i(1, 4)]
	var light_texture := _create_radial_light_texture()
	var seen: Dictionary = {}
	var layers: Array[TileMapLayer] = [
		$SewerTileMaps/DecorTileMapLayer,
	]
	for layer in layers:
		for cell: Vector2i in layer.get_used_cells():
			if layer.get_cell_atlas_coords(cell) in light_coords:
				var world_pos := layer.to_global(layer.map_to_local(cell))
				if world_pos not in seen:
					seen[world_pos] = true
					var light := PointLight2D.new()
					light.texture = light_texture
					light.color = water_light_color
					light.energy = water_light_energy
					light.texture_scale = water_light_texture_scale
					light.position = to_local(world_pos)
					add_child(light)


func _create_radial_light_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.colors = [Color.WHITE, Color(1.0, 1.0, 1.0, 0.0)]
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 128
	texture.height = 128
	return texture


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
