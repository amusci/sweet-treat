extends Machine
class_name MixingStation

func _ready():
	machine_type = "mixing"
	super._ready() # Pulls ready from Machine class

# Button press fucntionality
func _on_button_pressed():
	_attempt_crafting()
	print("helloo!!!")
