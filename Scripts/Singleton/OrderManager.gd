extends Node

###TODO: Money will eventually be implemented, please continue to stress yourself out about this
var available_recipes: Array = []
var active_orders: Array = []
var progress_by_order_id: Dictionary = {} 
@export var max_orders := 3
@export var spawn_interval : float # Randomized
var spawn_timer := 0.0

signal order_added(order_data)
signal order_removed(order_data)
#signal orders_restored(orders_array)
signal order_progress_updated(order_id) 

func _ready():
	# Make sure DataManager already loaded the recipes
	if DataManager.finished_recipes.size() > 0:
		init_recipes()
	else:
		print("No finished recipes available!")

func init_recipes():
	available_recipes = DataManager.finished_recipes.values()
	print("Loaded ", available_recipes.size(), " recipes:")
	for recipe in available_recipes:
		print("- ", recipe.title)

func _process(delta):
	# Update existing orders time_left
	for i in range(active_orders.size() - 1, -1, -1):
		var order_data = active_orders[i]
		order_data.time_left -= delta

		if order_data.time_left <= 0:
			print("Order expired: ", order_data.recipe.title)
			order_removed.emit(order_data)
			active_orders.remove_at(i)
			progress_by_order_id.erase(order_data.id)

	# Increment the spawn timer
	spawn_timer += delta

	# Only spawn if timer passed AND we are under the max orders
	if spawn_timer >= spawn_interval and active_orders.size() < max_orders:
		spawn_order()

func spawn_order():
	# Spawn the order
	var recipe = available_recipes.pick_random()
	var order_data = {
		"id": Time.get_unix_time_from_system() + randf(),
		"recipe": recipe,
		"time_left": recipe.time_to_make,
		"ingredients": recipe.ingredients,
		"tool_icon": recipe.tool_required_icon
	}
	active_orders.append(order_data)
	_init_order_progress(order_data)
	order_added.emit(order_data)
	print("Spawned order: ", recipe.title)

	# Reset timer AND pick next random interval for next spawn
	spawn_timer = 0.0
	spawn_interval = 10.0 + randf() * 10.0
	print("Next order in: ", spawn_interval, " seconds")

func remove_order_by_data(order_data):
	# Remove order functionality
	var index = active_orders.find(order_data)
	if index != -1:
		active_orders.remove_at(index)
		progress_by_order_id.erase(order_data.id)
		print("Removed order: ", order_data.recipe.title, " (", active_orders.size(), "/", max_orders, ")")
	else:
		print("Error: Could not find order to remove!")

func get_active_orders() -> Array:
	# Helper function to return active order array
	return active_orders

func get_order_by_id(order_id) -> Dictionary:
	# Helper function to return order id
	for order in active_orders:
		if order.id == order_id:
			return order
	return {}

func complete_order(order_data):
	remove_order_by_data(order_data)

func _init_order_progress(order_data: Dictionary) -> void:
	
	var order_id = order_data.id
	var final_recipe: Recipe = order_data.recipe
	var completed := PackedStringArray()
	var display_step := _compute_next_step_to_show(final_recipe, completed)
	var display_path := display_step.resource_path if display_step != null else final_recipe.resource_path

	progress_by_order_id[order_id] = {
		"completed_set": completed,
		"display_step_path": display_path,
	}

func get_display_step(order_id) -> Recipe:
	if not progress_by_order_id.has(order_id):
		var order = get_order_by_id(order_id)
		if order.is_empty():
			return null
		_init_order_progress(order)

	var display_path: String = progress_by_order_id[order_id].display_step_path
	var r := load(display_path)
	return r if r is Recipe else null

func notify_crafted_recipe(crafted_recipe: Recipe) -> void:
	# Forward only visual progress
	if crafted_recipe == null:
		return

	for order_data in active_orders:
		var order_id = order_data.id
		if not progress_by_order_id.has(order_id):
			_init_order_progress(order_data)

		var final_recipe: Recipe = order_data.recipe
		var prog = progress_by_order_id[order_id]
		var completed: PackedStringArray = prog.completed_set

		# If crafted recipe isn't part of this order at all SKIP
		if not _recipe_depends_on(final_recipe, crafted_recipe):
			continue

		# If already counted for this order SKIP
		if completed.has(crafted_recipe.resource_path):
			continue

		# Check to see if this is the step needed
		var next_needed := _compute_next_step_to_show(final_recipe, completed)
		if next_needed == crafted_recipe:
			# Mark done
			completed.append(crafted_recipe.resource_path)

			# Rechceck next display step
			var new_next := _compute_next_step_to_show(final_recipe, completed)
			var new_display_path := (new_next.resource_path if new_next != null else final_recipe.resource_path)

			# Move to next path that is deeper
			prog.completed_set = completed
			prog.display_step_path = new_display_path
			progress_by_order_id[order_id] = prog

			order_progress_updated.emit(order_id)
			# Return the first applicable order progresses
			return

	# If the crafted recipe is a parent later in the chain or not the immediate need, we ignore for now.

func _recipe_depends_on(final_recipe: Recipe, candidate: Recipe) -> bool:
	# Helper function to return if the recipe depends on the ingredient
	if final_recipe == candidate:
		return true
	for req in final_recipe.ingredients:
		var ing = req.ingredient
		if ing is Recipe and _recipe_depends_on(ing, candidate):
			return true
	return false

func _all_subrecipes_completed(r: Recipe, completed: PackedStringArray) -> bool:
	# Helper function to return if the subrecipe is completed
	for req in r.ingredients:
		var ing = req.ingredient
		if ing is Recipe:
			if not completed.has(ing.resource_path):
				return false
	return true

func _compute_next_step_to_show(target: Recipe, completed: PackedStringArray) -> Recipe:
	# Helper function to return the deepest missing subrecipe
	var missing := _find_first_missing_subrecipe(target, completed)
	return missing if missing != null else target

func _find_first_missing_subrecipe(r: Recipe, completed: PackedStringArray) -> Recipe:
	# Depth-first-search to find recipe we need
	for req in r.ingredients:
		var ing = req.ingredient
		if ing is Recipe:
			if not completed.has(ing.resource_path):
				# Before we can show r we must dive deeper
				var deeper := _find_first_missing_subrecipe(ing, completed)
				return deeper if deeper != null else ing
	# All subrecipes done
	return null
	
func clear_all_orders():
	active_orders.clear()
	progress_by_order_id.clear()
	spawn_timer = 0.0
	print("All orders cleared")
