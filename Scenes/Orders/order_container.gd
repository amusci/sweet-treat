# order_container.gd
extends VBoxContainer

###TODO: UI is hell

@export var order_scene: PackedScene
var orders_container: VBoxContainer
var order_instances: Dictionary = {}  # Track order instances by order_id instead of order_data

func _ready():
	# Get reference to self since this script IS the VBoxContainer
	orders_container = self
	
	# Connect signals from OrderManager
	OrderManager.order_added.connect(_on_order_added)
	OrderManager.order_removed.connect(_on_order_removed)
	
	# Restore existing orders when returning to this scene
	restore_existing_orders()

func restore_existing_orders():
	# Clear any existing UI elements first
	clear_all_orders()
	
	# Get all active orders from OrderManager and create UI for them
	var active_orders = OrderManager.get_active_orders()
	for order_data in active_orders:
		create_order_ui(order_data)

func clear_all_orders():
	# Clear the tracking dictionary
	order_instances.clear()
	
	# Remove all order UI elements
	for child in orders_container.get_children():
		child.queue_free()

func create_order_ui(order_data):
	# Create new order instance
	var order_instance = order_scene.instantiate()
	order_instance.setup(order_data)
	orders_container.add_child(order_instance)
	
	# Track this instance by order ID
	order_instances[order_data.id] = order_instance

func _on_order_added(order_data):
	# Only add if we don't already have UI for this order
	if not order_instances.has(order_data.id):
		create_order_ui(order_data)

func _on_order_removed(order_data):
	# Remove UI for the expired order
	remove_order_ui(order_data)

# Call this when an order is completed/expired to remove its UI
func remove_order_ui(order_data):
	if order_instances.has(order_data.id):
		var order_instance = order_instances[order_data.id]
		order_instances.erase(order_data.id)
		if is_instance_valid(order_instance):
			order_instance.queue_free()
