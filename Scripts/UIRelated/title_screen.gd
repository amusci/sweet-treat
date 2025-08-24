extends Control

@onready var play_button = $Play
@onready var settings_button = $Settings
@onready var exit_button = $Exit

var starting_money := 1000

func _ready():
	Money.money = starting_money # This will reset the players money 
	var music = preload("res://Assets/Music/Test Song.wav")
	music.loop_mode = AudioStreamWAV.LOOP_FORWARD
	MusicManager.play_music(music)
	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Areas/bakery_playground.tscn")
	OrderManager.clear_all_orders() # Clear all orders because I dont want to rewrite anything ATM
	print("Play Pressed")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Areas/UIScenes/Settings.tscn")
	print("Settings Pressed")

func _on_exit_pressed() -> void:
	get_tree().quit()
	print("Exit Pressed")
