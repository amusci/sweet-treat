extends Node2D

@onready var play_button = $Play
@onready var settings_button = $Settings
@onready var exit_button = $Exit


func _ready():
	pass
	


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Areas/bakery_playground.tscn")
	print("Play Pressed")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Areas/Title Screen/Settings.tscn")
	print("Settings Pressed")


func _on_exit_pressed() -> void:
	get_tree().quit()
	print("Exit Pressed")
