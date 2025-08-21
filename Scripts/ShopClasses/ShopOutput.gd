class_name ShopOutput
extends InventorySlot

func _ready():
	super._ready()
	# Remove from inventory_slots and add to shop_outputs
	remove_from_group("inventory_slots")
	add_to_group("shop_outputs")
	print("Added output slot to group: ", get_path())

func _process(_delta):
	super._process(_delta)
	
func _handle_click(right_click: bool):
	# Override click handling to prevent dropping items INTO the output slot
	if InventorySlot.currently_dragging_slot != null:
		# Don't allow dropping items into output slots
		print("Cannot drop items into output slot - output only!")
		return
	else:
		# Allow taking items OUT of the output slot
		_start_click_drag(right_click)

func _try_drop_here(_right_click: bool):
	# Override drop handling to prevent any drops
	print("Output slots are output-only!")
	return

func _start_click_drag(right_click: bool):
	# Override the drag start to ensure we can take items out
	if item == null:
		return
	
	# Use parent logic for starting drag
	super._start_click_drag(right_click)
	
func add_purchased_item(purchased_item: Resource, purchase_amount: int = 1):
	# Add purchased item to the slot
	if item == null:
		# Slot is empty, add the new item
		item = purchased_item
		amount = purchase_amount
	else:
		amount += purchase_amount
