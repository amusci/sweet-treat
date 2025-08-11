# order_container.gd
extends VBoxContainer
###TODO: UI is hell
@export var order_scene: PackedScene
var toggle_button: Button
var orders_container: VBoxContainer
var is_minimized = false
var order_instances: Dictionary = {}  # Track order instances by order_id instead of order_data

# Persist through scenes
static var persistent_order_state = false

func _ready():
	# Get references to child nodes
	toggle_button = get_node("ToggleButton")
	orders_container = get_node("OrdersContainer")
	
	# Restore the minimized state from the static variable
	is_minimized = persistent_order_state
	
	# Connect signals from OrderManager
	OrderManager.order_added.connect(_on_order_added)
	OrderManager.order_removed.connect(_on_order_removed)
	
	# Connect the toggle button - make sure this happens
	if toggle_button:
		if not toggle_button.pressed.is_connected(_on_toggle_button_pressed):
			toggle_button.pressed.connect(_on_toggle_button_pressed)
	
	# Restore existing orders when returning to this scene
	restore_existing_orders()
	
	# Apply the minimized state AFTER everything is set up
	call_deferred("apply_button_state")

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

func _on_toggle_button_pressed():
	if is_minimized:
		maximize_orders()
	else:
		minimize_orders()

func apply_button_state():
	# Force apply the correct state after everything is loaded
	print("Applying minimized state: ", is_minimized)  # Debug print
	if is_minimized:
		minimize_orders()
	else:
		maximize_orders()

func minimize_orders():
	# Minimize order functionality
	if orders_container:
		orders_container.visible = false
		if toggle_button:
			toggle_button.text = "Show Orders"
		is_minimized = true
		persistent_order_state = true

func maximize_orders():
	# Maximize order functionality
	if orders_container:
		orders_container.visible = true
		if toggle_button:
			toggle_button.text = "Hide Orders"
		is_minimized = false
		persistent_order_state = false
