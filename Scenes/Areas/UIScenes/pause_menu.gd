extends Control

const title_screen := "res://Scenes/Areas/UIScenes/title_screen.tscn"
@onready var music_slider = $Music
@onready var SFX_slider = $SFX

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_slider.value = MusicManager.get_current_volume()
	SFX_slider.value = SfxManager.get_current_volume()

func _on_button_pressed():
	get_tree().change_scene_to_file(title_screen)
	OrderManager.clear_all_orders()

func _on_music_value_changed(value):
	MusicManager.set_volume(value)

func _on_sfx_value_changed(value):
	SfxManager.set_volume(value)
