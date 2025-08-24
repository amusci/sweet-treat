extends Control

var label: Label
var recipe
var grid_container: GridContainer
var output_texture: TextureRect
var machine_texture: TextureRect
var order_id
var container_parent
var current_step_to_show: Recipe

func setup(order_data_param):
	order_id = order_data_param.id
	call_deferred("_get_container_parent")

	# Get references
	label = get_node("Label")
	grid_container = get_node("GridContainer")
	output_texture = get_node("OutputPanel/TextureRect")
	machine_texture = get_node("StationPanel/TextureRect")

	recipe = order_data_param.recipe

	# Always show customer's final order icon
	output_texture.texture = recipe.icon
	machine_texture.texture = recipe.tool_required_icon

	# Listen to progress updates
	if not OrderManager.order_progress_updated.is_connected(_on_order_progress_updated):
		OrderManager.order_progress_updated.connect(_on_order_progress_updated)

	# Initial display from OrderManager’s persisted state
	_refresh_step_from_manager()
	_update_display()
	_update_label(order_data_param)

func _on_order_progress_updated(updated_id):
	# Update progress of order
	if updated_id == order_id:
		_refresh_step_from_manager()
		_update_display()

func _refresh_step_from_manager():
	# Get step from OrderManager
	var step := OrderManager.get_display_step(order_id)
	current_step_to_show = step if step != null else recipe

func _update_display():
	# Update machine/tool for current step
	if current_step_to_show and "tool_required_icon" in current_step_to_show:
		machine_texture.texture = current_step_to_show.tool_required_icon
	else:
		machine_texture.texture = recipe.tool_required_icon

	# Update ingredients list for current step
	_update_ingredients_display()
	_update_goal_display()

func _update_ingredients_display():
	# Show the ingredients in the recipe
	for child in grid_container.get_children():
		child.queue_free()

	if current_step_to_show == null:
		return

	var ingredients_to_show = current_step_to_show.ingredients
	var ingredient_count = min(ingredients_to_show.size(), 6) # Up to 6

	for i in range(ingredient_count):
		var recipe_requirement = ingredients_to_show[i]
		var actual_ingredient = recipe_requirement.ingredient

		var ingredient_texture = TextureRect.new()
		ingredient_texture.texture = actual_ingredient.icon
		ingredient_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ingredient_texture.z_index = 1
		grid_container.add_child(ingredient_texture)

	var remaining_slots = 6 - ingredient_count
	for i in range(remaining_slots):
		var empty_texture = TextureRect.new()
		empty_texture.z_index = 1
		grid_container.add_child(empty_texture)

func _update_goal_display():
	# Debug pretty print
	if current_step_to_show == recipe:
		print("Final Step: " + recipe.title) 
	else:
		print("Next: " + current_step_to_show.title)

func _get_container_parent():
	# Get the container
	var current = get_parent()
	while current:
		if current.has_method("remove_order_ui"):
			container_parent = current
			break
		current = current.get_parent()

func _process(_delta):
	# Check if we have an order as well as update the timer
	var current_order_data = OrderManager.get_order_by_id(order_id)

	if current_order_data.is_empty():
		queue_free()
		return

	_update_label(current_order_data)

func _update_label(order_data):
	# Update timer
	if is_instance_valid(label):
		var time_left = int(order_data.time_left)
		label.text = str(time_left)

func get_order_data():
	# Helper function to get the order id data
	return OrderManager.get_order_by_id(order_id)
