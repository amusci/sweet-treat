# order.gd
extends Control

###TODO: Maybe a button the cancel orders you don't want to do?
######## Need to also show previous inbetween recipes.. no clue how to ######## do this...

var label: Label
var recipe
var grid_container: GridContainer
var panel_texture: TextureRect
var order_id  # Store unique ID 
var container_parent  # Order container

func setup(order_data_param):
	# Store the unique ID
	order_id = order_data_param.id
	
	# Get reference to the container parent
	call_deferred("_get_container_parent")
	
	# Get references to existing nodes in the scene
	label = get_node("Label")
	grid_container = get_node("GridContainer")
	panel_texture = get_node("Panel/TextureRect")
	
	# Set the output recipe texture in the top-left panel
	panel_texture.texture = order_data_param.recipe.icon
	
	# Clear existing grid items
	for child in grid_container.get_children():
		child.queue_free()
	
	# Populate grid with ingredients (up to 6 slots)
	var ingredient_count = min(order_data_param.ingredients.size(), 6)
	
	for i in range(ingredient_count):
		var recipe_requirement = order_data_param.ingredients[i]
		var actual_ingredient = recipe_requirement.ingredient
		
		# Create new TextureRect for this ingredient
		var ingredient_texture = TextureRect.new()
		ingredient_texture.texture = actual_ingredient.icon
		ingredient_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ingredient_texture.z_index = 1
		grid_container.add_child(ingredient_texture)
	
	# Fill remaining slots
	var remaining_slots = 6 - ingredient_count
	for i in range(remaining_slots):
		var empty_texture = TextureRect.new()
		empty_texture.z_index = 1
		grid_container.add_child(empty_texture)
	
	# Set up the rest of the order data
	recipe = order_data_param.recipe
	
	# Update label to show time left
	_update_label(order_data_param)

func _get_container_parent():
	# Find the order container parent
	var current = get_parent()
	while current:
		if current.has_method("remove_order_ui"):
			container_parent = current
			break
		current = current.get_parent()

func _process(delta):
	# Get the current order data from OrderManager using the order ID
	var current_order_data = OrderManager.get_order_by_id(order_id)
	
	if current_order_data.is_empty():
		# Order no longer exists in OrderManager REMOVE IT
		queue_free()
		return
	
	# Update the label with current time
	_update_label(current_order_data)

func _update_label(order_data):
	# Update label with time left
	if is_instance_valid(label):
		var time_left = int(order_data.time_left)
		label.text = str(time_left)

func get_order_data():
	# Helper function to get order data
	return OrderManager.get_order_by_id(order_id)
