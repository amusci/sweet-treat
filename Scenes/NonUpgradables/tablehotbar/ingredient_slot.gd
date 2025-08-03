extends Panel

@export var ingredient : Ingredient = null:
	set(value):
		ingredient = value
		
		if value == null:
			$Icon.texture = null
			$Amount.text = ""
			return
		
		$Icon.texture = value.icon
		
@export var amount := 0:
	set(value):
		amount = value
		$Amount.text = str(value)
		if amount <= 0:
			ingredient = null

# Drag state variables
var is_dragging = false
var drag_start_pos = Vector2.ZERO
var is_right_click_drag = false
var drag_preview = null
