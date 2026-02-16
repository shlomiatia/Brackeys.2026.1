class_name Interactable extends StaticBody2D

signal interacted

@onready var indicator: Sprite2D = $Indicator

func _ready() -> void:
	indicator.visible = false

# show or hide the interaction indicator
func set_can_interact(can_interact: bool) -> void:
	if indicator:
		indicator.visible = can_interact

# emit the interacted signal
func interact() -> void:
	interacted.emit()
