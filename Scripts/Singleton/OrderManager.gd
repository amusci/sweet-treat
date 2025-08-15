# ordermanager.gd
extends Node
###TODO: Money will eventually be implemented, please continue to stress yourself out about this
var available_recipes: Array = []
var active_orders: Array = []
@export var max_orders := 3
@export var spawn_interval := 1.0
var spawn_timer := 0.0
signal order_added(order_data)
signal order_removed(order_data) 
signal orders_restored(orders_array) 

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
	# Update existing orders time_left
	for i in range(active_orders.size() - 1, -1, -1):  # Iterate backwards to safely remove
		var order_data = active_orders[i]
		order_data.time_left -= delta
		
		if order_data.time_left <= 0:
			# Order expired
			print("Order expired: ", order_data.recipe.title)
			order_removed.emit(order_data)
			active_orders.remove_at(i)
	
	# Spawn an order if we under limit
	spawn_timer += delta
	if spawn_timer >= spawn_interval and active_orders.size() < max_orders:
		spawn_timer = 0.0
		spawn_order()

func spawn_order():
	# Spawn order functionality
	var recipe = available_recipes.pick_random() # Choose random recipe
	var order_data = { # House recipe data in dictionary
		"id": Time.get_unix_time_from_system() + randf(), # Unique ID
		"recipe": recipe,
		"time_left": recipe.time_to_make,
		"ingredients": recipe.ingredients,
		"tool_icon" : recipe.tool_required_icon
	}
	active_orders.append(order_data) # Create new order in array
	#print("New order: ", recipe.title, " (", active_orders.size(), "/", max_orders, ")")
	order_added.emit(order_data) # Tell our container to add an order

func remove_order_by_data(order_data):
	# Remove order functionality
	var index = active_orders.find(order_data)
	if index != -1:
		active_orders.remove_at(index)
		print("Removed order: ", order_data.recipe.title, " (", active_orders.size(), "/", max_orders, ")")
	else:
		print("Error: Could not find order to remove!")

func get_active_orders() -> Array:
	# Helper function to get active orders
	return active_orders


func get_order_by_id(order_id) -> Dictionary:
	# Helper function to get order id
	for order in active_orders:
		if order.id == order_id:
			return order
	return {}


func complete_order(order_data):
	# Complete order functionality
	remove_order_by_data(order_data)
	# TODO: MONEY TIME
