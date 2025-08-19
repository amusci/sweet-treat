extends Control

var music = AudioServer.get_bus_index("Music")
@onready var music_slider = $HSlider

func _ready():
	# Set slider to saved volume
	music_slider.value = MusicManager.get_current_volume()

func _on_h_slider_value_changed(value: float) -> void:
	MusicManager.set_volume(value)
	print("Volume Changed ", value)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Areas/UIScenes/title_screen.tscn")
