class_name DialogDisplayer extends Object

static func start(dialogue_name: String) -> void:
	Global.can_control = false

	Dialogic.start(dialogue_name)
	await Dialogic.timeline_ended

	Global.can_control = true
