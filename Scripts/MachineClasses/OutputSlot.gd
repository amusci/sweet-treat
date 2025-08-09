class_name OutputSlot
extends InventorySlot

# Monitor for changes to item and amount from parent class
var _last_item = null
var _last_amount = 0

func _ready():
	super._ready()
	
	# Start hidden
	_update_visibility()
	
	# Remove from inventory_slots and add to output_slots
	remove_from_group("inventory_slots")
	add_to_group("output_slots")
	print("Added output slot to group: ", get_path())

func _process(_delta):
	super._process(_delta)
	
	# Check if item or amount changed and update visibility
	if item != _last_item or amount != _last_amount:
		_last_item = item
		_last_amount = amount
		_update_visibility()

func _update_visibility():
	# Show/hide the slot based on output item
	var should_be_visible = item != null and amount > 0
	visible = should_be_visible
	
	if should_be_visible:
		print("Output slot now visible with: ", amount, "x ", item.title if item else "unknown")
	else:
		print("Output slot hidden (empty)")

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

# Override the drag start to ensure we can take items out
func _start_click_drag(right_click: bool):
	if item == null:
		return
	
	# Use parent logic for starting drag
	super._start_click_drag(right_click)

func set_output_item(output_item: Resource, output_amount: int = 1):
	# Add method to set item programmatically (for machines to use)
	# Use the inherited properties directly
	item = output_item
	amount = output_amount
	_update_visibility()

func clear_output():
	# Add method to clear the output slot
	item = null
	amount = 0
	_update_visibility()

func has_output() -> bool:
	# Helper Function to check if the output slot has an item
	return item != null and amount > 0

func get_output_description() -> String:
	# Helper function to get a description of what's in the output slot
	if not has_output():
		return "Empty"
	return str(amount) + "x " + item.title
