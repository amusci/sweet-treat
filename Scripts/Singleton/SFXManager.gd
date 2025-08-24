extends Node

var SFX_player: AudioStreamPlayer
var current_song: AudioStream
var current_volume: float = 0.3

const SAVE_FILE = "user://settings.ini"

func _ready():
	# On ready we make a new audio stream player and load our volume 
	SFX_player = AudioStreamPlayer.new()
	add_child(SFX_player)
	SFX_player.bus = "SFX"
	load_volume_setting()

func play_SFX(song: AudioStream):
	# Play the SFX passed in
	current_song = song
	SFX_player.stream = song
	SFX_player.play()

func set_volume(volume: float):
	# Set volume of music
	current_volume = volume
	SFX_player.volume_db = linear_to_db(volume)
	save_volume_setting()

func get_current_volume() -> float:
	# Helper function that returns the current volume
	return current_volume

func save_volume_setting():
	# Save current volume
	var config = ConfigFile.new()
	config.set_value("audio", "SFX_volume", current_volume)
	config.save(SAVE_FILE)

func load_volume_setting():
	# Load the saved volume
	var config = ConfigFile.new()
	var save_file = config.load(SAVE_FILE)
	if save_file == OK: # If the file exists
		current_volume = config.get_value("audio", "SFX_volume", 0.3)
	set_volume(current_volume)
