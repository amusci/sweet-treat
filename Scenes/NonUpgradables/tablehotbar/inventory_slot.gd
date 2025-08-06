class_name InventorySlot
extends Panel

@export var item : Resource = null:
	# The item currently in this slot
	set(value):
		item = value
		
		if value == null:
			$Icon.texture = null
			$Amount.text = ""
			return
		
		$Icon.texture = value.icon
		
@export var amount := 0:
	# The amount current in this slot
	set(value):
		amount = value
		$Amount.text = str(value)
		if amount <= 0:
			item = null

# Dragging variables shared across every slot (static)
static var currently_dragging_slot = null # slot being dragged from
static var drag_preview = null # visual preview of the item being dragged
static var is_right_click_mode = false # if the drag is right click initated

func _ready():
	
	# Add slot to group
	add_to_group("inventory_slots")
	print("Added slot to group: ", get_path())
	
	# Connect GUI input to handle mouse clicks
	gui_input.connect(_on_gui_input)

func _process(_delta):
	# Follow the mouse with the drag preview
	if currently_dragging_slot == self and drag_preview:
		var mouse_pos = get_global_mouse_position()
		drag_preview.global_position = mouse_pos - drag_preview.size / 2

func _on_gui_input(event):
	# Detect mouse clicks
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_click(false)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_click(true)

func _handle_click(right_click: bool):
	# What to do with our click
	if currently_dragging_slot != null:
		# If we are already dragging, drop into current slot
		_try_drop_here(right_click)
	else:
		# If we aren't dragging, let's start
		_start_click_drag(right_click)

func _start_click_drag(right_click: bool):
	# What to do when we click
	if item == null: # Do I really need to explain this Lukas
		return
	
	currently_dragging_slot = self
	is_right_click_mode = right_click # true or false
	
	print("PICKED UP ", amount, " ", item.title)
	
	# Create drag preview
	_create_drag_preview()

func _try_drop_here(_right_click: bool):
	# How to handle dropping the drag
	if currently_dragging_slot == self:
		# Cancel drop if dropping ontop of current slot
		_cancel_drag()
		return
	
	# Dropping ontop new slot
	if is_right_click_mode:
		_handle_right_click_drop_here() 
	else:
		_handle_left_click_drop_here()
	
	# Clean up drag state
	_end_drag()

func _cancel_drag():
	# Cancel drag logic and clean up
	
	#print("CANCELLED DRAG")
	_cleanup_drag_preview()
	currently_dragging_slot = null
	is_right_click_mode = false

func _end_drag():
	# End drag logic and clean up
	
	# print("DROPPED ITEM")
	_cleanup_drag_preview()
	currently_dragging_slot = null
	is_right_click_mode = false


func _cleanup_drag_preview():
	# Good bye drag preview
	if drag_preview:
		drag_preview.queue_free()
		drag_preview = null

func _create_drag_preview():
	# Hello drag preview
	if not item:
		return
	
	# Create a preview of the dragged item
	drag_preview = Control.new()
	drag_preview.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	drag_preview.size = size
	drag_preview.z_index = 100
	drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.2, 0.8)
	bg.size = size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_preview.add_child(bg)

	var icon = TextureRect.new()
	icon.texture = item.icon
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size = $Icon.size
	icon.position = $Icon.position
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_preview.add_child(icon)

	### TODO: uhh do we want to see the amount? idk kind of weird and whats the point?
	
	#var drag_amount = amount
	#if is_right_click_mode and amount > 1:
		#drag_amount = 1
	
	#if drag_amount > 1:
		#var amount_label = Label.new()
		#amount_label.text = str(drag_amount)
		#amount_label.size = $Amount.size
		#amount_label.position = Vector2(25,23)
		#amount_label.add_theme_color_override("font_color", Color.WHITE)
		#amount_label.add_theme_font_size_override("font_size", 4)
		#amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		#drag_preview.add_child(amount_label)
	
	# Add to scene
	get_tree().root.add_child(drag_preview)

func _handle_left_click_drop_here():
	# LEFT CLICK DROP LOGIC
	var source_slot = currently_dragging_slot
	
	# Left click: move entire stack or swap items
	if item == null:
		# Target slot is empty move the item to that slot
		item = source_slot.item
		amount = source_slot.amount
		source_slot.item = null
		source_slot.amount = 0
	else:
		# Target slot has item check if same type
		if item == source_slot.item:
			# Same item type COMBINE
			amount += source_slot.amount
			source_slot.item = null
			source_slot.amount = 0
		else:
			# Different item types SWAP
			var temp_item = item
			var temp_amount = amount
			
			item = source_slot.item
			amount = source_slot.amount
			
			source_slot.item = temp_item
			source_slot.amount = temp_amount

func _handle_right_click_drop_here():
	# RIGHT CLICK DROP LOGIC
	var source_slot = currently_dragging_slot
	
	# If target slot is not empty
	if item != null:
		# Check if the current item is the same as the dropped slot
		if item == source_slot.item:
			amount += 1 # If the same ADD ONE 
			if source_slot.amount <= 1:
				# If source slot had 1 of the item and we are dropping WE OBVIOUSLY CANT DUPLICATE
				source_slot.item = null
				source_slot.amount = 0
			else:
				# Source slot had multiple items REDUCE BY ONE
				source_slot.amount -= 1
		# If different item types do nothing right click is NOT MERGE
		return
	
	# If Target slot is empty
	if source_slot.amount <= 1:
		# Only one item MOVE THE ITEM
		item = source_slot.item
		amount = 1
		source_slot.item = null
		source_slot.amount = 0
	else:
		# Multiple items MOVE ONE OF THE ITEM
		item = source_slot.item
		amount = 1
		source_slot.amount -= 1
