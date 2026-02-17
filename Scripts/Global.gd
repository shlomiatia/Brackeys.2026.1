extends Node

# vars regarding what the player can control
var can_control: bool = true

func format_collected_letters() -> void:
	var collected: String = Dialogic.VAR.get_variable("collected_letters")
	var spaced := " ".join(collected.split(""))
	Dialogic.VAR.set_variable("letters_display", spaced)


func validate_statue_answer() -> void:
	var collected: String = Dialogic.VAR.get_variable("collected_letters")
	var answer: String = Dialogic.VAR.get_variable("user_answer")
	var allowed := collected.to_lower()

	for c in answer.to_lower():
		if c not in allowed:
			Dialogic.VAR.set_variable("answer_result", "missing")
			return

	if answer.to_lower() == "lies":
		Dialogic.VAR.set_variable("answer_result", "correct")
	else:
		Dialogic.VAR.set_variable("answer_result", "incorrect")
