extends Node2D
@onready var layers: Array[Node] = get_children()

var current_id := ""

func play_ambience(id: String, streams: Array[AudioStream]):
	if id == current_id:
		return
		
	current_id = id
	
	for i in layers.size():
		if i < streams.size():
			_fade_in(layers[i], streams[i])
		else:
			_fade_out(layers[i])
			
			
func _fade_in(player: AudioStreamPlayer, stream: AudioStream):
	if player.stream != stream:
		player.stream = stream
		player.volume_db = -60
		player.play()

	create_tween().tween_property(player, "volume_db", 0, 2.0)


func _fade_out(player: AudioStreamPlayer):
	create_tween().tween_property(player, "volume_db", -60, 2.0)
