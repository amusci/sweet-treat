extends Node

var saved_slots: Dictionary = {} # Dictionary to hold save data
const containers : Array = ["Hotbar"] # If we have more containers add it here but i dont think we will?

func save_all_inventory_slots():
	# Find all inventory slots in the group
	print("=== SAVING INVENTORY ===")
	var slots = get_tree().get_nodes_in_group("inventory_slots")
	#print("Found ", slots.size(), " slots in group")
	for slot in slots:
		if slot is InventorySlot:
			var slot_id = _get_slot_identifier(slot) # Get the slot
			#print("Saving slot: ", slot_id, " Item: ", slot.item, " Amount: ", slot.amount)
			saved_slots[slot_id] = { # Append slot to dictionary
				"item": slot.item,
				"amount": slot.amount
			}
			
	print("Total saved slots: ", saved_slots.size())

func restore_all_inventory_slots():
	# Restore slots based on save data 
	print("=== RESTORING INVENTORY ===")
	await get_tree().process_frame # BEFORE THE PROCESS RUNS 
	var slots = get_tree().get_nodes_in_group("inventory_slots") # Get the inventory_slots group
	#print("Found ", slots.size(), " slots in group for restore")
	#print("Have ", saved_slots.size(), " saved slots")
	for slot in slots:
		if slot is InventorySlot:
			var slot_id = _get_slot_identifier(slot) # Find the slot ID
			if saved_slots.has(slot_id):
				var data = saved_slots[slot_id] # Restore the data in the slot from the saved data
				#print("Restoring slot: ", slot_id, " Item: ", data.item, " Amount: ", data.amount)
				slot.item = data.item
				slot.amount = data.amount
			else:
				print("No saved data for slot: ", slot_id)

func _get_slot_identifier(slot) -> String:
	# Helper function to get the Parent.Slot 
	
	if "slot_id" in slot and slot.slot_id != "":
		return slot.slot_id
	var current = slot.get_parent() 
	while current != null and current.name != "root":
		# Check if this node is in the machines group
		if current.is_in_group("machines"):
			return current.name + "." + slot.name
		# Check if node is in containers
		if current.name in containers:
			return current.name + "." + slot.name
		current = current.get_parent()
	# Fallback
	return slot.get_parent().name + "." + slot.name
