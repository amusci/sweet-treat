extends Area2D
class_name Fridge
@onready var inventory = $Inventory
var is_open = false

func _ready():
	is_open = false
	input_event.connect(_on_input_event)
	inventory.hide()

func _on_input_event(viewport, event, shape_idx):
	# If we click the fridge and it's not open, open. if open not open
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_open = !is_open
		inventory.visible = is_open
