extends Node

const MAX_PLAYERS: int = 16

var players: Array[AudioStreamPlayer] = []

func _ready():
	print('SFX Manager has started! woo!')
	for i in MAX_PLAYERS:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		players.append(p)


func play(stream: AudioStream, volume_db: float = 0.0, pitch: float = 1.0):
	for p in players:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.pitch_scale = pitch
			p.play()
			return
	
