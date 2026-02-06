extends CharacterBody2D

const SPEED: float = 100.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d = $Area2D

# allows for setting the direction the sprite is facing every scene
@export var current_direction: String = "Bck"

 # makes sure the the player is facing the right direction upon entering scene
func _ready() -> void:
	animated_sprite.play("idle" + current_direction)

# get the input direction and handle movement
func _physics_process(_delta: float) -> void:
	if Global.player_can_move: # only allow movement if the player can move
		var direction: Vector2 = Vector2(Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")).normalized()
		if direction:
			velocity = direction * SPEED
			# play the right animation when moving
			animated_sprite.play("walk" + current_direction)
			
			# sets player direction according to the last direction the player was moving in
			current_direction = return_dir(direction)
			
		else: # stop movement/walking if player isn't moving
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)
			animated_sprite.play("idle" + current_direction)
			
		move_and_slide()
	else: # needed to stop walking animation when interacting
		animated_sprite.play("idle" + current_direction)
		velocity = Vector2.ZERO
		
# returns a direction depending on the direction the player is moving
func return_dir(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "L" if dir.x < 0 else "R"
	else:
		return "Bck" if dir.y < 0 else "Fr"
