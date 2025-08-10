extends VBoxContainer

###TODO: Need to make this way more clean


@export var order_scene: PackedScene

func _ready():
	# Connect signals from OrderManager
	OrderManager.order_added.connect(_on_order_added)
	OrderManager.order_removed.connect(_on_order_removed)

func _on_order_added(order_data):
	# Add order to the container
	var order_instance = order_scene.instantiate()
	order_instance.setup(order_data) # Set up the order
	add_child(order_instance)

func _on_order_removed(order_node):
	# Remove order from the container
	if order_node.get_parent() == self: # If the container is the parent to the order
		order_node.queue_free()
