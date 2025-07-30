extends Area2D
# Current ingredients in the mixing station
var current_ingredients: Dictionary = {} # {key: Resource, value: amount}
 # Check to see if mouse is hovering
var is_mouse_over = false
# Load recipes that require this mixing station
var available_recipes: Array[Recipe] = []


func _load_recipes():
	### TODO: need to load this using DataManager in the future
	var recipe_files = [
		"res://Resources/RecipeResources/InbetweenRecipeResources/self_rising_dough.tres",
	]
	for recipe_path in recipe_files:
		var recipe = load(recipe_path) as Recipe
		if recipe and recipe.tool_required == "mixing":  # Only load recipes for mixing station
			available_recipes.append(recipe)
	
	print("Loaded ", available_recipes.size(), " mixing recipes")

func _ready():
	# Input signal to handle clicks on machine
	input_event.connect(_on_input_event)
	# Load recipes for this station
	_load_recipes()

func _on_input_event(viewport, event, shape_idx):
	#Mouse button handler
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Put item in machine
			_handle_left_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("HERE ARE THE INGREDIENTS SINCE YOU DONT TRUST YOUR OWN CODE LOL")
			if current_ingredients.is_empty():
				print("nothing... there is legit NOTHING")
			for ingredient in current_ingredients:
				print("  ", ingredient.title, ": ", current_ingredients[ingredient])
			
			
func _on_button_pressed():
	_attempt_crafting()
	
func _handle_left_click():
	# LEFT CLICK LOGIC
	if InventorySlot.currently_dragging_slot != null:
		# If we are dragging an item, consume it
		var dragging_slot = InventorySlot.currently_dragging_slot
		var dragging_item = dragging_slot.item
		
		if dragging_item != null:
			_consume_ingredient(dragging_slot, dragging_item)

func _attempt_crafting():
	# This function will be run on a button we want to mix
	print("Attempting to craft...")
	var crafted_recipe = _check_for_recipes()
	if crafted_recipe == null:
		print("No valid recipes found with current ingredients")
	else:
		_craft_recipe(crafted_recipe)
		
func _consume_ingredient(slot, item_resource):
	# CONSUMING LOGIC
	if item_resource == null or slot == null:
		return
	
	print("Took one of ", item_resource.title)
	
	# Add item to current ingredient dictionary
	if item_resource in current_ingredients:
		current_ingredients[item_resource] += 1
	else:
		current_ingredients[item_resource] = 1
		
	#Debug pretty print
	print("\nCurrent ingredients:")
	for ingredient in current_ingredients:
		print("  ", ingredient.title, ": ", current_ingredients[ingredient])
	
	# Remove 1 of the item from the dragging slot
	if slot.amount <= 1:
		# If only 1 item 0 item
		slot.item = null
		slot.amount = 0
		# NO MORE DRAG STATE 
		InventorySlot.currently_dragging_slot = null
		InventorySlot.is_right_click_mode = false
		# Clean up the preview
		if InventorySlot.drag_preview:
			InventorySlot.drag_preview.queue_free()
			InventorySlot.drag_preview = null
	else:
		# If more than 1 remove 1
		slot.amount -= 1

func _can_craft_recipe(recipe: Recipe) -> bool:
	# Check if we have all required ingredients in correct amounts
	for requirement in recipe.ingredients:
		var required_ingredient = requirement.ingredient
		# Check if we have this ingredient in our mixing station
		if not (required_ingredient in current_ingredients):
			return false
		# ASSUME WE ONLY NEED 1 INGREDIENT
		if current_ingredients[required_ingredient] < 1:
			return false
	
	return true

func _check_for_recipes() -> Recipe:
	# Check loaded recipe to see if machine satisfied requirements
	for recipe in available_recipes:
		if _can_craft_recipe(recipe):
			print("Found matching recipe for: ", recipe.title)
			return recipe
	
	return null


func _craft_recipe(recipe: Recipe):
	# CRAFTING LOGIC
	print("Crafting: ", recipe.title)
	
	# Consume the required ingredients
	for requirement in recipe.ingredients:
		var required_ingredient = requirement.ingredient
		# Take 1 of each ingredient from dictionary
		current_ingredients[required_ingredient] -= 1
		
		# Remove ingredient from dictionary if amount reaches 0
		if current_ingredients[required_ingredient] <= 0:
			current_ingredients.erase(required_ingredient) # foo dot erase btw

	# Pretty print
	print("Remaining ingredients:")
	if current_ingredients.is_empty():
		print("  (empty)")
	else:
		for ingredient in current_ingredients:
			print("  ", ingredient.title, ": ", current_ingredients[ingredient])
	
	# TODO: Add the crafted item to player inventory or output slot
	# Announce what was made for now
	print("Successfully crafted: ", recipe.title)
	print("Description: ", recipe.description)
	
	# Return the recipe so you can use it to create the actual item
	return recipe
