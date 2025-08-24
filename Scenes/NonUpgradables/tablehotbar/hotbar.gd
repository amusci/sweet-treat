extends Control

func _ready() -> void:
	# Loop through all children 
	for child in get_children():
		# Only add InventorySlot children to the group
		if child is InventorySlot:
			child.add_to_group("hotbar")
			print("Added slot to hotbar group:", child.name)
"res://Assets/TempAssets/Baking_Soda.png"
