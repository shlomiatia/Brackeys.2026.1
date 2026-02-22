class_name Player extends CharacterBody2D

const SPEED: float = 100.0

var speed_modifier: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d = $Area2D

# allows for setting the direction the sprite is facing every scene
@export var current_direction: String = "Bck"

var interact_sfx = load("res://audio/sfx/interactions/sfx_ui_interact_1.mp3")
 # makes sure the the player is facing the right direction upon entering scene
func _ready() -> void:
	animated_sprite.play("idle" + current_direction)
	area_2d.body_entered.connect(_on_area_body_entered)
	area_2d.body_exited.connect(_on_area_body_exited)

# get the input direction and handle movement
func _physics_process(_delta: float) -> void:
	if !Global.can_control:
		animated_sprite.play("idle" + current_direction)
		return

	
	var direction = Vector2(Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")).normalized()

	if direction:
		velocity = direction * (SPEED + speed_modifier)
		# play the right animation when moving
		animated_sprite.play("walk" + current_direction)

		# sets player direction according to the last direction the player was moving in
		current_direction = return_dir(direction)

	else: # stop movement/walking if player isn't moving
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		animated_sprite.play("idle" + current_direction)

	move_and_slide()

	# Handle interaction input
	if Input.is_action_just_pressed("interact"):
		_try_interact()
		
# returns a direction depending on the direction the player is moving
func return_dir(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "L" if dir.x < 0 else "R"
	else:
		return "Bck" if dir.y < 0 else "Fr"
		
# try to interact with the first interactable in the area
func _try_interact() -> void:
	var overlapping_bodies = area_2d.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("interactables"):
			AudioManager.play_sfx(interact_sfx, "SFX", -6.0)
			body.interact()
			break

# called when an interactable enters the area
func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactables"):
		body.set_can_interact(true)

# called when an interactable exits the area
func _on_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactables"):
		body.set_can_interact(false)
