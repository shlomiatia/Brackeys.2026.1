class_name DialogDisplayer extends Object

static func start(dialogue_name: String) -> void:
	Global.player_can_move = false
	Global.player_can_interact = false

	Dialogic.start(dialogue_name)
	await Dialogic.timeline_ended

	Global.player_can_move = true
	Global.player_can_interact = true
