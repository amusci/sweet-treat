extends VBoxContainer
@export var order_scene: PackedScene
var orders_container: VBoxContainer
var order_instances: Dictionary = {} # Track order instances by order_id instead of order_data

func _ready():
	add_to_group("order_containers")
	orders_container = self

	OrderManager.order_added.connect(_on_order_added)
	OrderManager.order_removed.connect(_on_order_removed)

	restore_existing_orders() # Restore orders on scene switch

func restore_existing_orders():
	# Restore existing order on scene switch
	clear_all_orders()
	var active_orders = OrderManager.get_active_orders()
	for order_data in active_orders:
		create_order_ui(order_data)

func clear_all_orders():
	# CLEAR ALL THEM ORDERS
	order_instances.clear()
	for child in orders_container.get_children():
		child.queue_free()

func create_order_ui(order_data):
	# Create an order using the data from OrderManager
	var order_instance = order_scene.instantiate()
	order_instance.setup(order_data)
	orders_container.add_child(order_instance)
	order_instances[order_data.id] = order_instance

func _on_order_added(order_data):
	# If the order doesnt exist, create it
	if not order_instances.has(order_data.id):
		create_order_ui(order_data)

func _on_order_removed(order_data):
	# Remove order from UI
	remove_order_ui(order_data)

func remove_order_ui(order_data):
	# Remove order from dictionary and UI
	if order_instances.has(order_data.id):
		var order_instance = order_instances[order_data.id]
		order_instances.erase(order_data.id)
		if is_instance_valid(order_instance):
			order_instance.queue_free()
