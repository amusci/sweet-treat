extends HBoxContainer

@onready var storage_button = $StorageButton
@onready var baking_button = $BakingButton

func _on_baking_button_pressed():
	if _get_current_scene("res://Scenes/Areas/bakery_playground.tscn"):
		return  # Do nothing if already in bakery
	
	InventoryManager.save_all_inventory_slots()
	TransitionScreen.transition()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/Areas/bakery_playground.tscn")

func _on_storage_button_pressed():
	if _get_current_scene("res://Scenes/Areas/storage_playground.tscn"):
		return  # Do nothing if already in storage
	
	InventoryManager.save_all_inventory_slots()
	TransitionScreen.transition()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/Areas/storage_playground.tscn")

func _ready():
	call_deferred("restore_inventory")
	_update_button_states()  # Update buttons when scene loads

func restore_inventory():
	InventoryManager.restore_all_inventory_slots()

func _get_current_scene(scene_path: String) -> bool:
	# Helper function to return if we are trying to access the same scene we are in
	var current_scene = get_tree().current_scene.scene_file_path
	return current_scene == scene_path

func _update_button_states():
	# Disable the button for the current scene
	if _get_current_scene("res://Scenes/Areas/bakery_playground.tscn"):
		baking_button.disabled = true
		storage_button.disabled = false
	elif _get_current_scene("res://Scenes/Areas/storage_playground.tscn"):
		storage_button.disabled = true
		baking_button.disabled = false
