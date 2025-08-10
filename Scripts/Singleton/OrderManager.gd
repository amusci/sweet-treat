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
	if DataManager.finished_recipes.size() > 0:
		init_recipes()
	else:
		print("No finished recipes available!")

func init_recipes():
	# Put the available recipes into an array
	available_recipes = DataManager.finished_recipes.values()
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
		"time_left": recipe.time_to_make
	}
	
	active_orders.append(order_data) # Create new order in array
	print("New order: ", recipe.title, " (", active_orders.size(), "/", max_orders, ")")
	order_added.emit(order_data) # Tell our container to add an order

func remove_order(order_node):
	# Remove order functionality
	for i in range(active_orders.size()):
		if active_orders[i].recipe == order_node.recipe: # Make sure our array aligns with the UI
			active_orders.remove_at(i) # Remove that order from the array
			break
	
	print("Order removed: ", order_node.recipe.title, " (", active_orders.size(), "/", max_orders, ")")
	order_removed.emit(order_node) # Tell our container to remove the order
