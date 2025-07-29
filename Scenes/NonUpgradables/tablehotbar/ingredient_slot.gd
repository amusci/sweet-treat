extends Panel

@export var item : Resource = null:
	
	# Able to add a item to the slot
	
	set(value):
		item = value
		
		if value == null:
			$Icon.texture = null
			$Amount.text = ""
			return
		
		$Icon.texture = value.icon
		
@export var amount := 0:
	
	# Able to set an amount to the item in the slot
	
	set(value):
		amount = value
		$Amount.text = str(value)
		if amount <= 0:
			item = null

# Drag state variables

var is_dragging = false
var drag_start_pos = Vector2.ZERO
var is_right_click_drag = false
var drag_preview = null

# Drag threshold to prevent accidental drags

const DRAG_THRESHOLD = 5

func _ready():
	
	# Connect mouse signals
	
	gui_input.connect(_on_gui_input)

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.global_position, false)
			else:
				_end_drag(event.global_position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_start_drag(event.global_position, true)
			else:
				_end_drag(event.global_position)
	
	elif event is InputEventMouseMotion and is_dragging:
		_update_drag(event.global_position)

func _start_drag(pos: Vector2, right_click: bool):
	
	# Dragging is true
	
	if item == null:
		return
	
	is_dragging = true
	drag_start_pos = pos
	is_right_click_drag = right_click
	print("I AM CURRENTLY DRAGGING " , amount, " " , item.title)
	
	# Create drag preview
	
	_create_drag_preview()

func _update_drag(pos: Vector2):
	if not is_dragging:
		return
	
	# Check if we've moved enough to start visual dragging
	if drag_start_pos.distance_to(pos) > DRAG_THRESHOLD:
		if drag_preview:
			drag_preview.global_position = pos - drag_preview.size / 2

func _end_drag(pos: Vector2):
	if not is_dragging:
		return
	
	is_dragging = false
	
	# Clean up preview
	if drag_preview:
		drag_preview.queue_free()
		drag_preview = null
	
	# Only process drop if we moved enough distance
	if drag_start_pos.distance_to(pos) > DRAG_THRESHOLD:
		_process_drop(pos)

func _create_drag_preview():
	if not item:
		return
	
	# Create a visual preview of the dragged item
	drag_preview = Control.new()
	drag_preview.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	drag_preview.size = size
	drag_preview.z_index = 100
	
	# Add background
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.2, 0.8)
	bg.size = size
	drag_preview.add_child(bg)
	
	# Add icon
	var icon = TextureRect.new()
	icon.texture = item.icon
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size = $Icon.size
	icon.position = $Icon.position
	drag_preview.add_child(icon)
	
	# Add amount text if more than 1
	var drag_amount = amount
	if is_right_click_drag and amount > 1:
		drag_amount = 1
	
	if drag_amount > 1:
		var amount_label = Label.new()
		amount_label.text = str(drag_amount)
		amount_label.size = $Amount.size
		amount_label.position = Vector2(25,23) # lukas fault
		amount_label.add_theme_color_override("font_color", Color.WHITE)
		amount_label.add_theme_font_size_override("font_size", 4)
		drag_preview.add_child(amount_label)
	
	# Add to scene tree
	get_tree().root.add_child(drag_preview)

func _process_drop(drop_pos: Vector2):
	# Find the target slot under the mouse
	var target_slot = _find_slot_at_position(drop_pos)
	
	if target_slot == null or target_slot == self:
		return
	
	# Process the drop based on click type
	if is_right_click_drag:
		_handle_right_click_drop(target_slot)
	else:
		_handle_left_click_drop(target_slot)

func _find_slot_at_position(pos: Vector2) -> Panel:
	# Get all inventory slots in the scene
	var slots = _get_all_inventory_slots()
	
	for slot in slots:
		if slot == self:
			continue
		
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(pos):
			return slot
	
	return null

func _get_all_inventory_slots() -> Array:
	# This function should return all inventory slots in your game
	# You might need to adjust this based on your scene structure
	var slots = []
	_find_inventory_slots_recursive(get_tree().root, slots)
	return slots

func _find_inventory_slots_recursive(node: Node, slots: Array):
	# Check if this node is an inventory slot (has the same script)
	if node.get_script() == get_script() and node != self:
		slots.append(node)
	
	# Recursively check children
	for child in node.get_children():
		_find_inventory_slots_recursive(child, slots)

func _handle_left_click_drop(target_slot: Panel):
	# Left click: move entire stack or swap items
	if target_slot.item == null:
		# Target slot is empty move our item there
		target_slot.item = item
		target_slot.amount = amount
		item = null
		amount = 0
	else:
		# Target slot has item check if same type
		if target_slot.item == item:
			# Same item type combine stacks
			target_slot.amount += amount
			item = null
			amount = 0
		else:
			# Different item types swap them
			var temp_item = target_slot.item
			var temp_amount = target_slot.amount
			
			target_slot.item = item
			target_slot.amount = amount
			
			item = temp_item
			amount = temp_amount

func _handle_right_click_drop(target_slot: Panel):
	# Right click take one item from stack
	if target_slot.item != null:
		# Check if it's the same item type stack them
		if target_slot.item == item:
			target_slot.amount += 1
			if amount <= 1:
				# We only had one item remove it entirely
				item = null
				amount = 0
			else:
				# We had multiple items reduce by one
				amount -= 1
		# If different item types do nothing
		return
	
	if amount <= 1:
		# Only one item move it entirely
		target_slot.item = item
		target_slot.amount = 1
		item = null
		amount = 0
	else:
		# Multiple items move one
		target_slot.item = item
		target_slot.amount = 1
		amount -= 1
