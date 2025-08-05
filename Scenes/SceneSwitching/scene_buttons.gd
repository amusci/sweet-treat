extends HBoxContainer


func _ready():
	call_deferred("restore_inventory")

func restore_inventory():
	# For the call_deferred
	InventoryManager.restore_all_inventory_slots()

func _on_baking_button_pressed():
	# Baking Button Functionality
	if _get_current_scene("res://Scenes/Areas/bakery_playground.tscn"):
		return
	
	InventoryManager.save_all_inventory_slots()
	TransitionScreen.transition()
	
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/Areas/bakery_playground.tscn")

func _on_storage_button_pressed():
	# Storage Button Functionality
	if _get_current_scene("res://Scenes/Areas/storage_playground.tscn"):
		return
	InventoryManager.save_all_inventory_slots()
	TransitionScreen.transition()
	
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/Areas/storage_playground.tscn")
	
func _get_current_scene(scene_path: String) -> bool:
	# Helper function to return if we are trying to access the same scene we are in
	var current_scene = get_tree().current_scene.scene_file_path
	return current_scene == scene_path
