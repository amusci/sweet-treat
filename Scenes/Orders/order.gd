# order.gd
extends VBoxContainer
###TODO: Maybe a button the cancel orders you don't want to do?
######## Need to also show previous inbetween recipes.. no clue how to ######## do this...
var progress_bar: ProgressBar
var label: Label
var recipe
var recipe_container: HBoxContainer
var order_id  # Store unique ID 
var container_parent  # Order container

func setup(order_data_param):
	# Store the unique ID
	order_id = order_data_param.id
	
	# Get reference to the container parent
	call_deferred("_get_container_parent")
	
	# Load these as they are instantiated
	progress_bar = get_node("ProgressBar") 
	label = get_node("Label")
	recipe_container = get_node("RecipeContainer")
	
	# Clear any existing recipe display
	for child in recipe_container.get_children():
		child.queue_free()
	
	# Add ingredient sprites
	for i in range(order_data_param.ingredients.size()):
		var recipe_requirement = order_data_param.ingredients[i]
		var actual_ingredient = recipe_requirement.ingredient
		
		# Create sprite for ingredient
		var ingredient_sprite = TextureRect.new()
		ingredient_sprite.texture = actual_ingredient.icon
		ingredient_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ingredient_sprite.custom_minimum_size = Vector2(32, 32)
		recipe_container.add_child(ingredient_sprite)
		
		# Add + between ingredients
		if i < order_data_param.ingredients.size() - 1:
			var plus_label = Label.new()
			plus_label.text = " + "
			plus_label.add_theme_font_size_override("font_size", 16)
			plus_label.add_theme_color_override("font_color", Color.BLACK)
			recipe_container.add_child(plus_label)
	
	# Add equals sign to signify output
	var equals_label = Label.new()
	equals_label.text = " = "
	equals_label.add_theme_font_size_override("font_size", 16)
	equals_label.add_theme_color_override("font_color", Color.BLACK)
	recipe_container.add_child(equals_label)
	
	# Add final recipe 
	var recipe_sprite = TextureRect.new()
	recipe_sprite.texture = order_data_param.recipe.icon
	recipe_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	recipe_sprite.custom_minimum_size = Vector2(32, 32)
	recipe_container.add_child(recipe_sprite)
	
	# Set up the rest of the order data
	recipe = order_data_param.recipe
	
	# Show recipe name
	label.text = "Order: %s" % order_data_param.recipe.title
	progress_bar.max_value = 100.0

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
	
	if is_instance_valid(progress_bar):
		var max_time = current_order_data.recipe.time_to_make
		var time_left = current_order_data.time_left
		
		# DO NOT DIVIDE BY 0
		if max_time > 0:
			var progress_percentage = max(0.0, (time_left / max_time) * 100.0)
			progress_bar.value = progress_percentage
			
			#print("Order: ", current_order_data.recipe.title, " Time left: ", time_left, " Max: ", max_time, " Progress: ", progress_percentage)
		else:
			progress_bar.value = 0.0

func get_order_data():
	return OrderManager.get_order_by_id(order_id)
