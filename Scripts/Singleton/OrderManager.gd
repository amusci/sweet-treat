extends Node

###TODO: Money will eventually be implemented, please continue to stress yourself out about this


var available_recipes: Array = []
var active_orders: Array = []
@export var max_orders := 3
@export var spawn_interval := 5.0
var spawn_timer := 0.0

signal order_added(order_data)
signal order_removed(order_node)

func _ready():
	# Make sure DataManager already loaded the recipes
	if DataManager.inbetween_recipes.size() > 0:
		init_recipes()
	else:
		print("No finished recipes available!")

func init_recipes():
	# Put the available recipes into an array
	available_recipes = DataManager.inbetween_recipes.values()
	print("Loaded ", available_recipes.size(), " recipes:")
	for recipe in available_recipes:
		print("- ", recipe.title)

func _process(delta):
	# Spawn an order if we arent at our limit
	spawn_timer += delta
	if spawn_timer >= spawn_interval and active_orders.size() < max_orders:
		spawn_timer = 0.0
		spawn_order()

func spawn_order():
	# Spawn order functionality		
	var recipe = available_recipes.pick_random() # Choose random recipe
	var order_data = { # House recipe data in dictionary
		"recipe": recipe,
		"time_left": recipe.time_to_make,
		"ingredients" : recipe.ingredients,
	}
	active_orders.append(order_data) # Create new order in array
	print("New order: ", recipe.title, " (", active_orders.size(), "/", max_orders, ")")
	order_added.emit(order_data) # Tell our container to add an order

func remove_order_by_data(order_data):
	var index = active_orders.find(order_data)
	if index != -1:
		active_orders.remove_at(index)
		print("Removed order: ", order_data.recipe.title, " (", active_orders.size(), "/", max_orders, ")")
		# Note: You'll need to handle the UI removal in your container script
		# since we don't have the order_node here to emit with
	else:
		print("Error: Could not find order to remove!")
