extends VBoxContainer

###TODO: UI is hell

@export var order_scene: PackedScene

var toggle_button: Button
var orders_container: VBoxContainer
var is_minimized = false

func _ready():
	# Get references to child nodes
	toggle_button = get_node("ToggleButton")
	orders_container = get_node("OrdersContainer")
	# Connect signals from OrderManager
	OrderManager.order_added.connect(_on_order_added)
	OrderManager.order_removed.connect(_on_order_removed)

func _on_order_added(order_data):
	# Add order to the orders container (not self)
	var order_instance = order_scene.instantiate()
	order_instance.setup(order_data) # Set up the order
	orders_container.add_child(order_instance)  # Add to orders_container instead of self

func _on_order_removed(order_node):
	# Remove order from the container
	if order_node.get_parent() == orders_container:  # Check if orders_container is the parent
		order_node.queue_free()

func _on_toggle_button_pressed():
	if is_minimized:
		maximize_orders()
	else:
		minimize_orders()

func minimize_orders():
	if orders_container:
		# Hide all orders
		orders_container.visible = false
		# Update button text
		if toggle_button:
			toggle_button.text = "Show Orders"
		is_minimized = true

func maximize_orders():
	if orders_container:
		# Show all orders
		orders_container.visible = true
		# Update button text
		if toggle_button:
			toggle_button.text = "Hide Orders"
		is_minimized = false
