extends Area2D

@export var ambience_id: String
@export var streams: Array[AudioStream]

func _on_body_entered(body):
	if body.is_in_group("player"):
		$"../../Layers".play_ambience(ambience_id, streams)
