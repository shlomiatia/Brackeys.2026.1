@tool
extends BaseInteractable

## export vars for adjusting per scene
@export var animation_player: AnimationPlayer = null
@export var dialogue_name: String = ""
@export var animation_name: String = ""

# connects signals
func _ready() -> void:
	super._ready()
	update_properties() # makes sure the properties update at runtime
	if not Engine.is_editor_hint(): # only does the following in-game
		Dialogic.signal_event.connect(_on_dialogic_signal)
		interacted.connect(_on_interacted)
		animation_player.animation_finished.connect(animation_finished)

# calls update_properties
func _process(_delta: float) -> void:
	super._process(_delta)
	if Engine.is_editor_hint():
		super.update_properties() # super needed to reference functions in base class

# start interaction sequence with animation
func _on_interacted():
	Global.interaction_state = 'anim' # sets interaction state (see comments in Global script)
	disable_player()
	animation_player.play(animation_name)

# triggers animation when it receives a specific signal
# if you don't want any animation before the dialogue, trigger this
# at the beginning of the animation (not frame 0.0)
func _on_dialogic_signal(argument: String):
	# set a signal in dialogic with this name at the end of the dialogue
	if argument == "resume" + animation_name:
		animation_player.play(animation_name)
	
# pauses animation and starts dialogue again. Trigger from animation_player
func start_dialogue_from_animation():
	animation_player.pause()
	Dialogic.start(dialogue_name)

# enables player and disables this interaction area so the player can no longer interact with it
func animation_finished(anim_name):
	 # only trigger if its the correct animation/state
	if anim_name == animation_name and Global.interaction_state == 'anim':
		# vars referenced from base class
		player_in_area = false # needs to be set before calling set_interaction
		able_to_interact = false
		
		set_interaction()
		Global.interaction_state = ''
		enable_player()
