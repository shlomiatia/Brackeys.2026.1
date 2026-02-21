extends Node2D

# Mask Mini Game - Movement
var mask_position_threshold: float = 8.0
var mask_rotation_threshold_deg: float = 8.0
var mask_min_step_duration: float = 1.0
var mask_max_step_duration: float = 2.5
var mask_max_position: float = 75.0
var mask_max_rotation_deg: float = 45.0
var mask_min_distance_from_origin: float = 16.0

# Maze Hint
var maze_modulate_hint_modifier: float = 0.8
var maze_db_hint_modifier: float = 24.0


var canvas_layer: CanvasLayer
var display_label: Label
var current_property_index: int = 0
var current_category_index: int = 0
var properties: Array = []
var categories: Array = []

var timer = 0
const is_disabled = false

func _ready():
	if is_disabled:
		return

	categories = [
		{
			"name": "Mask Movement",
			"properties": [
                ["mask_position_threshold", 1],
				["mask_rotation_threshold_deg", 1],
				["mask_min_step_duration", 0.1],
				["mask_max_step_duration", 0.1],
				["mask_max_position", 1],
				["mask_max_rotation_deg", 1],
				["mask_min_distance_from_origin", 1],
				]
		},
		{
			"name": "Maze Hint",
			"properties": [
				["maze_modulate_hint_modifier", 0.05],
				["maze_db_hint_modifier", 0.5],
				]
		}
	]

	properties = categories[current_category_index]["properties"]

	setup_ui()
	update_display()
	print_all_values()


func setup_ui():
	canvas_layer = CanvasLayer.new()

	get_parent().add_child.call_deferred(canvas_layer)

	display_label = Label.new()
	display_label.set_anchors_preset(Control.PRESET_TOP_RIGHT, true)
	display_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	display_label.grow_vertical = Control.GROW_DIRECTION_END
	display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	display_label.add_theme_constant_override("margin_right", 10)
	display_label.add_theme_constant_override("margin_top", 10)
	canvas_layer.add_child.call_deferred(display_label)
	display_label.visible = false


func _input(event: InputEvent):
	if is_disabled:
		return

	if (Input.is_action_just_pressed("ui_text_completion_replace")):
		display_label.visible = !display_label.visible;

	if event.is_action_pressed("ui_right"):
		current_property_index = (current_property_index + 1) % properties.size()
		update_display()

	elif event.is_action_pressed("ui_left"):
		current_property_index = (current_property_index - 1) % properties.size()
		if current_property_index < 0:
			current_property_index = properties.size() - 1
		update_display()

	elif event.is_action_pressed("ui_page_up"):
		change_category(1)

	elif event.is_action_pressed("ui_page_down"):
		change_category(-1)

	elif event.is_action_pressed("ui_up"):
		timer = 0
		adjust_current_value(1)

	elif event.is_action_pressed("ui_down"):
		timer = 0
		adjust_current_value(-1)

func change_category(direction: int):
	current_category_index = (current_category_index + direction) % categories.size()
	if current_category_index < 0:
		current_category_index = categories.size() - 1

	properties = categories[current_category_index]["properties"]
	current_property_index = 0
	update_display()

func arrays_match(arr1, arr2):
	if arr1.size() != arr2.size():
		return false

	for i in range(arr1.size()):
		if arr1[i] != arr2[i]:
			return false

	return true

func _process(delta: float) -> void:
	if is_disabled:
		return
	if Input.is_action_pressed("ui_up"):
		timer += delta
		if timer > 0.2:
			adjust_current_value(1)

	elif Input.is_action_pressed("ui_down"):
		timer += delta
		if timer > 0.2:
			adjust_current_value(-1)

func adjust_current_value(direction: float):
	var var_name = properties[current_property_index][0]
	var amt = properties[current_property_index][1];
	var currentNum = get(var_name);
	var newNum = currentNum + direction * amt;

	if amt == 0:
		if currentNum == 0:
			newNum = 1;
		else:
			newNum = 0;

	set(var_name, newNum);
	update_display()
	print_all_values()

func update_display():
	var var_name = properties[current_property_index][0]
	var current_value = get(var_name)
	var category_name = categories[current_category_index]["name"]
	var fps = Engine.get_frames_per_second()

	display_label.text = "[%s]\n%s: %.2f\nFPS: %d" % [
		category_name,
		var_name,
		current_value,
		fps
	]

func print_all_values():
	print("\nCurrent Values:")
	print("----------------")
	for var_name in properties:
		var current_value = get(var_name[0])
		print("%s: %.2f" % [var_name, current_value])
	print("----------------")
