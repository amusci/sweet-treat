extends Node2D

var music = AudioServer.get_bus_index("Music")
@onready var music_slider = $HSlider

func _ready(): 
	print(music_slider.value)
	AudioServer.set_bus_volume_db(music, linear_to_db(.3))
	


	
func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music, linear_to_db(value))
	print("Volume Changed ", value)
