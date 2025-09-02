extends Node

const title_screen := "res://Scenes/Areas/UIScenes/title_screen.tscn"

func _ready():
	SfxManager.play_SFX(SfxManager.gameover)
	OrderManager.orders_spawning = false
	OrderManager.clear_all_orders() # Clear all orders since we dead twin

func _process(_delta):
	if Input.is_action_just_pressed("Spacebar"):
		SfxManager.play_SFX(SfxManager.click)
		get_tree().change_scene_to_file(title_screen)
