extends VBoxContainer

###TODO: Maybe a button the cancel orders you don't want to do?
######## Needs to show sprite + SPRITE + sPrItE = RECIPE
######## Need to also show previous inbetween recipes.. no clue how to do this...

var progress_bar: ProgressBar
var label: Label
var recipe
var recipe_container: HBoxContainer
var time_left: float
var max_time: float
var order_data

func setup(order_data_param):
	# Order setup functionality
	order_data = order_data_param # New variable alert
	# Need to load these two as they are instantiated
	progress_bar = get_node("ProgressBar") 
	label = get_node("Label")

	recipe_container = get_node("RecipeContainer")
	
	# Clear any existing recipe display
	for child in recipe_container.get_children():
		child.queue_free()
	
	# Add ingredient sprites
	for i in range(order_data.ingredients.size()):
		var recipe_requirement = order_data.ingredients[i]
		var actual_ingredient = recipe_requirement.ingredient
		
		# Create sprite for ingredient
		var ingredient_sprite = TextureRect.new()
		ingredient_sprite.texture = actual_ingredient.icon
		ingredient_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ingredient_sprite.custom_minimum_size = Vector2(32, 32) # We are doing 32x32 right?
		recipe_container.add_child(ingredient_sprite)
		
		# Add + between ingredients
		if i < order_data.ingredients.size() - 1:
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
	recipe_sprite.texture = order_data.recipe.icon
	recipe_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	recipe_sprite.custom_minimum_size = Vector2(32, 32) # 32x32
	recipe_container.add_child(recipe_sprite)
	
	# Set up the rest of the order data
	recipe = order_data.recipe
	time_left = order_data.time_left
	max_time = order_data.recipe.time_to_make
	# Show recipe name
	label.text = "Order: %s" % order_data.recipe.title

	
	progress_bar.max_value = 100.0
	progress_bar.value = 100.0

func _process(delta):
	if time_left > 0:
		time_left -= delta
		# Calculate progress 
		if progress_bar != null:
			progress_bar.value = (time_left / max_time) * 100.0
		
		if time_left <= 0:
			# Order expired
			OrderManager.remove_order_by_data(order_data)
			queue_free()
