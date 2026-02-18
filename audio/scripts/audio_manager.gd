extends Node
@onready var music_player: AudioStreamPlayer2D = $MusicPlayer
@onready var sfx_root: Node = $SFXRoot

var current_music: AudioStream = null
var music_tween: Tween = null

var master_volume := 0.0
var music_volume := 0.0
var sfx_volume := 0.0

var debug_audio := true

func _ready():
	print("AudioManager on start")


# MUSIC 
func play_music(stream: AudioStream, fade_time := 1.0):
	if stream == current_music:
		return
		
	if music_tween:
		music_tween.kill()
	
	music_tween = create_tween()
	
	if music_player.playing:
		music_tween.tween_property(music_player, "volume_db", -40, fade_time)
		
		await music_tween.finished
		music_player.stop()
		
	current_music = stream
	music_player.stream = stream
	music_player.volume_db = -40
	music_player.play()
	
	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", 0, fade_time)

func stop_music(fade_time := 1.0):
	if not music_player.playing:
		return

	if music_tween:
		music_tween.kill()

	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", -40, fade_time)
	await music_tween.finished

	music_player.stop()
	current_music = null
	
func duck_music(amount_db := -10, time := 0.5):
	if music_tween:
		music_tween.kill()
		
	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", amount_db, time)
	
func restore_music(time := 0.5):
	if music_tween:
		music_tween.kill()
		
	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", 0, time)
	
# SFX 

func play_sfx(stream: AudioStream, bus := "SFX", volume_db := 0.0, pitch := 1.0):
	var player := AudioStreamPlayer2D.new()
	
	player.stream = stream
	player.bus = bus
	player.volume_db = volume_db
	player.pitch_scale = pitch
	sfx_root.add_child(player)
	player.play()
	
	player.finished.connect(func():
		player.queue_free()
		)

func play_ui(stream: AudioStream):
	play_sfx(stream, "UI")

# DEBUGGING
func log(msg):
	if debug_audio:
		print("[Pete AudioManager] ", msg)
