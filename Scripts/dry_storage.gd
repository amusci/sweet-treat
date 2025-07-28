extends Node2D
@onready var machine_sprite = $MachineSprite
@onready var inventory_sprite = $InventorySprite


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	
	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			print("mb1")
