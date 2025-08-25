extends Control

@onready var music_slider = $MusicSlider
@onready var SFX_slider = $SFXSlider

var test = preload("res://Assets/SFX/openmenu.wav")

func _ready():
	# Set slider to saved volume
	music_slider.value = MusicManager.get_current_volume()
	SFX_slider.value = SfxManager.get_current_volume()
	
func _on_music_slider_value_changed(value):
	MusicManager.set_volume(value)
	print("Volume Changed ", value)

func _on_sfx_slider_value_changed(value):
	SfxManager.set_volume(value)
	print("Volume Changed ", value)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Areas/UIScenes/title_screen.tscn")

func _on_test_sfx_pressed():
	SfxManager.play_SFX(test)
