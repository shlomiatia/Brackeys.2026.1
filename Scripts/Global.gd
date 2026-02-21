extends Node

# vars regarding what the player can control
var can_control: bool = true
var ending_name: String = ""
var came_from_ending: bool = false
var incorrect_statue_count: int = 0

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        Dialogic.Inputs.auto_skip.enabled = !Dialogic.Inputs.auto_skip.enabled

func change_scene(scene_path: String) -> void:
    can_control = false
    var fade: Fade = get_tree().current_scene.get_node("CanvasLayer/Fade")
    await fade.fade_out()
    get_tree().change_scene_to_file(scene_path)

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
    elif answer.to_lower() == "self":
        Dialogic.VAR.set_variable("answer_result", "self")
    else:
        Dialogic.VAR.set_variable("answer_result", "incorrect")
        incorrect_statue_count += 1
        if incorrect_statue_count == 3:
            Dialogic.VAR.set_variable("bella_suspects_statues", true)
