extends Area2D
class_name Machine

var current_ingredients: Dictionary = {} # {key: Resource, value: amount}
var is_mouse_over = false
var available_recipes: Array[Recipe] = [] 

# Reference to the output slot node 
@export var output_slot: OutputSlot = null

# Machine-specific properties
var machine_type: String = "" # "mixing", "bakingsheet", "oven"
var recipe_folder_path: String = "" # Path to recipes for this machine type

# Persistence properties
@export var machine_id: String = "" # Unique identifier for this machine instance

func _ready():
	add_to_group("machines") # Add machine to machines group
	# Common setup for all machines
	input_event.connect(_on_input_event)
	
	# Set machine_id if not already set (fallback to node name + machine_type)
	if machine_id.is_empty():
		machine_id = name + "_" + machine_type
	
	# Try to find output slot if not assigned
	if output_slot == null:
		output_slot = find_child("OutputSlot") as OutputSlot
		if output_slot == null:
			print("Warning: No OutputSlot found for ", machine_type, " machine output")
	
	_load_recipes()
	_load_machine_state() # Load persisted state

func _exit_tree():
	# Save machine state when leaving the scene
	_save_machine_state()

func _load_recipes():
	# Wait for DataManager to load
	if not DataManager.data_loaded.is_connected(_on_data_loaded):
		DataManager.data_loaded.connect(_on_data_loaded)
	
	# If data is already loaded, load recipes
	if DataManager.inbetween_recipes.size() > 0 or DataManager.finished_recipes.size() > 0:
		_load_recipes_from_data_manager()

func _on_data_loaded():
	_load_recipes_from_data_manager()

func _load_recipes_from_data_manager():
	# Load from both inbetween and finished recipes
	var all_recipes = {}
	all_recipes.merge(DataManager.inbetween_recipes)
	all_recipes.merge(DataManager.finished_recipes)
	
	for recipe_id in all_recipes:
		var recipe = all_recipes[recipe_id] as Recipe
		if recipe and recipe.tool_required == machine_type:
			# print(recipe.title)
			available_recipes.append(recipe)
	
	print("Loaded ", available_recipes.size(), " recipes for ", machine_type, " station")


func _save_machine_state():
	# Save ingredients in machine
	if not MachineManager:
		print("Warning: MachineManager not found, cannot save machine state")
		return
	
	var machine_data = {
		"current_ingredients": _serialize_ingredients(),
		"output_item": _serialize_output_item(),
		"machine_type": machine_type
	}
	
	MachineManager.set_machine_data(machine_id, machine_data)

func _load_machine_state():
	# Load ingredients in machine
	if not MachineManager:
		print("Warning: MachineManager not found, cannot load machine state")
		return
	
	var machine_data = MachineManager.get_machine_data(machine_id)
	if machine_data == null:
		return
	
	# Restore ingredients
	current_ingredients = _deserialize_ingredients(machine_data.get("current_ingredients", {}))
	
	# Restore output item if it exists
	var output_data = machine_data.get("output_item", {})
	if not output_data.is_empty() and output_slot != null:
		_deserialize_output_item(output_data)

func _serialize_ingredients() -> Dictionary:
	# Convert current_ingredients to a saveable format
	var serialized = {}
	for ingredient in current_ingredients:
		if ingredient is Resource:
			# Save by resource path
			serialized[ingredient.resource_path] = current_ingredients[ingredient]
		else:
			print("Warning: Non-resource ingredient found: ", ingredient)
	return serialized

func _deserialize_ingredients(serialized_data: Dictionary) -> Dictionary:
	# Convert saved data back to ingredient dictionary
	var ingredients = {}
	for resource_path in serialized_data:
		var ingredient = load(resource_path)
		if ingredient != null:
			ingredients[ingredient] = serialized_data[resource_path]
		else:
			print("Warning: Could not load ingredient from path: ", resource_path)
	return ingredients

func _serialize_output_item() -> Dictionary:
	# Save output slot contents
	if output_slot == null or not output_slot.has_output():
		return {}
	
	var output_data = {
		"item_path": "",
		"amount": output_slot.amount
	}
	
	if output_slot.item is Resource:
		output_data["item_path"] = output_slot.item.resource_path
	
	return output_data

func _deserialize_output_item(output_data: Dictionary):
	# Restore output slot contents
	if output_data.is_empty() or output_slot == null:
		return
	
	var item_path = output_data.get("item_path", "")
	var amount = output_data.get("amount", 0)
	
	if item_path != "" and amount > 0:
		var item = load(item_path)
		if item != null:
			output_slot.set_output_item(item, amount)
		else:
			print("Warning: Could not load output item from path: ", item_path)

func _on_input_event(viewport, event, shape_idx):
	# Mouse input handling
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_pretty_print()

func _pretty_print():
	# Pretty Print
	print("=== ", machine_type.to_upper(), " STATION INGREDIENTS ===")
	if current_ingredients.is_empty():
		print("No ingredients currently in machine")
	else:
		for ingredient in current_ingredients:
			print("  ", ingredient.title, ": ", current_ingredients[ingredient])

func _handle_left_click():
	# Left click handling
	if InventorySlot.currently_dragging_slot != null:
		var dragging_slot = InventorySlot.currently_dragging_slot
		var dragging_item = dragging_slot.item
		
		if dragging_item != null:
			_consume_ingredient(dragging_slot, dragging_item)

func _consume_ingredient(slot, item_resource):
	# Makes sure ingredient exists, if the ingredient can be put in the machine put it in the machine
	if item_resource == null or slot == null:
		return
	
	# Check if this ingredient can be used in this machine type
	if not _can_accept_ingredient(item_resource):
		print("This machine cannot accept ", item_resource.title)
		return
	
	print("Added ", item_resource.title, " to ", machine_type, " station")
	
	# Add item to current ingredient dictionary
	if item_resource in current_ingredients:
		current_ingredients[item_resource] += 1
	else:
		current_ingredients[item_resource] = 1
	
	# Debug print current ingredients
	_pretty_print()
	
	# Remove item from inventory slot
	_remove_item_from_slot(slot)
	
	# Save state immediately after ingredient change
	_save_machine_state()

func _remove_item_from_slot(slot):
	# Remove amount of 1 from the slot
	if slot.amount <= 1:
		slot.item = null
		slot.amount = 0
		# Clean up drag state when slot becomes empty
		InventorySlot.currently_dragging_slot = null
		InventorySlot.is_right_click_mode = false
		if InventorySlot.drag_preview:
			InventorySlot.drag_preview.queue_free()
			InventorySlot.drag_preview = null
	else:
		# If multiple items in stack reduce by 1 
		slot.amount -= 1
		# Clean up drag and drop remaining items back to original slot
		if slot.item != null:
			slot.get_node("Icon").texture = slot.item.icon
			slot.get_node("Amount").text = str(slot.amount)
		
		# Clean up drag state
		InventorySlot.currently_dragging_slot = null
		InventorySlot.is_right_click_mode = false
		if InventorySlot.drag_preview:
			InventorySlot.drag_preview.queue_free()
			InventorySlot.drag_preview = null

func _can_accept_ingredient(ingredient) -> bool:
	# Helper function that returns true or false if the machine can accept the inputted ingredient
	for recipe in available_recipes:
		for requirement in recipe.ingredients:
			if requirement.ingredient == ingredient:
				return true
	return false

func _can_craft_recipe(recipe: Recipe) -> bool:
	# Helper function that returns true or false if the recipe can be crafted from the ingredients in the machine
	for requirement in recipe.ingredients:
		var required_ingredient = requirement.ingredient
		if not (required_ingredient in current_ingredients):
			return false
		# Use the actual required amount from the recipe
		var required_amount = requirement.amount if "amount" in requirement else 1
		if current_ingredients[required_ingredient] < required_amount:
			return false
	return true

func _check_for_recipes() -> Recipe:
	# Helper function that checks if there is a recipe with the current ingredients
	for recipe in available_recipes:
		if _can_craft_recipe(recipe):
			print("Found matching recipe for: ", recipe.title)
			return recipe
	return null

func _craft_recipe(recipe: Recipe):
	# Recipe crafting handling
	print("Crafting: ", recipe.title, " in ", machine_type, " station")
	
	# Make sure output slot is empty or else won't craft
	if output_slot != null and output_slot.has_output():
		print("Output slot is full! Clear it before crafting.")
		return null
	
	# Use required ingredients
	for requirement in recipe.ingredients:
		var required_ingredient = requirement.ingredient
		var required_amount = requirement.amount if "amount" in requirement else 1
		current_ingredients[required_ingredient] -= required_amount
		
		if current_ingredients[required_ingredient] <= 0:
			current_ingredients.erase(required_ingredient)
	
	# Debug print remaining ingredients
	print("Remaining ingredients after crafting:")
	if current_ingredients.is_empty():
		print("  (empty)")
	else:
		_pretty_print()
	
	# Put the crafted recipe in the output slot
	_handle_crafted_item(recipe)
	
	# Save state after crafting
	_save_machine_state()
	
	print("Successfully crafted: ", recipe.title)
	return recipe


func _handle_crafted_item(recipe: Recipe):
	# Output handling
	if output_slot == null:
		print("Error: No output slot available for crafted item!")
		return
	
	# Create the crafted recipe and put it in the output slot
	var crafted_item = _create_item_from_recipe(recipe)
	if crafted_item:
		var output_amount = _get_recipe_output_amount(recipe)
		output_slot.set_output_item(crafted_item, output_amount)
		print("Crafted ", output_amount, "x ", crafted_item.title, " - ready for collection!")

func _create_item_from_recipe(recipe: Recipe):
	# Convert recipe to an actual item
	if "output_item" in recipe:
		return recipe.output_item
	else:
		print("Recipe ", recipe.title, " doesn't specify output_item property")
		return recipe

func _get_recipe_output_amount(recipe: Recipe) -> int:
	# Get how many items this recipe produces
	if "output_amount" in recipe:
		return recipe.output_amount
	else:
		return 1  # Default to 1 item


func _can_attempt_crafting() -> bool:
	# Helper function to see if the machine can actually output
	return output_slot == null or not output_slot.has_output()

func _attempt_crafting():
	# Crafting handling (checks to make sure the output is empty, we can craft, and the recipe exists)
	if not _can_attempt_crafting():
		print("Cannot craft - output slot is full! Collect the item first.")
		return
		
	print("Attempting to craft in ", machine_type, " station...")
	var crafted_recipe = _check_for_recipes()
	if crafted_recipe == null:
		print("No valid recipes found with current ingredients")
	else:
		_craft_recipe(crafted_recipe)
