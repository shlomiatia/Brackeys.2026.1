class_name DialogDisplayer extends Object

static func start(dialogue_name: String) -> void:
	Global.can_control = false
	AudioManager.duck_music(-10, 1.25)
	Dialogic.start(dialogue_name)
	await Dialogic.timeline_ended
	AudioManager.restore_music(1.25)
	Global.can_control = true
