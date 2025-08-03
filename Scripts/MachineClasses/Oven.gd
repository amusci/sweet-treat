extends Machine
class_name Oven

func _ready():
	machine_type = "oven"
	super._ready() # Pulls ready from Machine class

func _on_button_pressed():
	# Button functionality
	_attempt_crafting()
