extends Control

@onready var play_button = $Play
@onready var settings_button = $Settings
@onready var exit_button = $Exit

@onready var settings_toggle = $SettingsToggle
@onready var sfx_slider = $SettingsToggle/SFXSlider
@onready var button = $SettingsToggle/Button
@onready var music_slider = $SettingsToggle/MusicSlider

var starting_money := 1000
var show_settings := false

func _ready():
	show_settings = false
	settings_toggle.visible = false
	Engine.time_scale = 1.0
	
	# Set slider to saved volume
	music_slider.value = MusicManager.get_current_volume()
	sfx_slider.value = SfxManager.get_current_volume()
	
	OrderManager.orders_spawning = false
	Money.money = starting_money # This will reset the players money 
	var music = preload("res://Assets/Music/Test Song.wav")
	music.loop_mode = AudioStreamWAV.LOOP_FORWARD
	MusicManager.play_music(music)
	
func _on_play_pressed() -> void:
	SfxManager.play_SFX(SfxManager.play)
	get_tree().change_scene_to_file("res://Scenes/Areas/bakery_playground.tscn")
	OrderManager.orders_spawning = true
	OrderManager.clear_all_orders() # Clear all orders because I dont want to rewrite anything ATM
	OrderManager.spawn_order()
	print("Play Pressed")

func _on_settings_pressed() -> void:
	SfxManager.play_SFX(SfxManager.click)
	show_settings = !show_settings
	settings_toggle.visible = show_settings
	#get_tree().change_scene_to_file("res://Scenes/Areas/UIScenes/Settings.tscn")
	print("Settings Pressed")

func _on_exit_pressed() -> void:
	get_tree().quit()
	print("Exit Pressed")
	
func _on_music_slider_value_changed(value):
	MusicManager.set_volume(value)
	print("Volume Changed ", value)


func _on_sfx_slider_value_changed(value):
	SfxManager.set_volume(value)
	print("Volume Changed ", value)


func _on_button_pressed():
	SfxManager.play_SFX(SfxManager.no)
