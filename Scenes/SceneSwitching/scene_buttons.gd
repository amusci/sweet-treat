extends HBoxContainer

func _on_baking_button_pressed():
	InventoryManager.save_all_inventory_slots()
	get_tree().change_scene_to_file("res://Scenes/Areas/bakery_playground.tscn")

func _on_storage_button_pressed():
	InventoryManager.save_all_inventory_slots()
	get_tree().change_scene_to_file("res://Scenes/Areas/storage_playground.tscn")

func _ready():
	# Wait for all nodes to be ready, then restore inventory
	call_deferred("restore_inventory")

func restore_inventory():
	InventoryManager.restore_all_inventory_slots()
