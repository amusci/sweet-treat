extends Node

const title_screen := "res://Scenes/Areas/UIScenes/title_screen.tscn"

func _ready():
	OrderManager.clear_all_orders() # Clear all orders since we dead twin

func _on_button_pressed():
	get_tree().change_scene_to_file(title_screen)
