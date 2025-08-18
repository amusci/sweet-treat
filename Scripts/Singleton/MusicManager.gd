extends Node

var music_player: AudioStreamPlayer
var current_song: AudioStream
var current_volume: float = 0.3

const SAVE_FILE = "user://settings.ini"

func _ready():
	# On ready we make a new audio stream player and load our volume 
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"
	load_volume_setting()

func play_music(song: AudioStream):
	# Play the song passed into the function 
	if current_song != song:
		current_song = song
		music_player.stream = song
		music_player.play()

func stop_music():
	# Stop
	music_player.stop()

func set_volume(volume: float):
	# Set volume of music
	current_volume = volume
	music_player.volume_db = linear_to_db(volume)
	save_volume_setting()

func pause_music():
	# Pause
	music_player.stream_paused = true

func resume_music():
	# Resume
	music_player.stream_paused = false

func get_current_volume() -> float:
	# Helper function that returns the current volume
	return current_volume

func save_volume_setting():
	# Save current volume
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", current_volume)
	config.save(SAVE_FILE)

func load_volume_setting():
	# Load the saved volume
	var config = ConfigFile.new()
	var save_file = config.load(SAVE_FILE)
	if save_file == OK: # If the file exists
		current_volume = config.get_value("audio", "music_volume", 0.3)
		# config.get_value(section, key, default_value)
	set_volume(current_volume)
