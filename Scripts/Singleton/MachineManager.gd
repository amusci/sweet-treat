extends Node

var machine_states: Dictionary = {} # Stores Machine States

func _ready():
	# Machine states start empty 
	machine_states.clear()

func set_machine_data(machine_id: String, data: Dictionary):
	# Machine state management
	machine_states[machine_id] = data

func get_machine_data(machine_id: String) -> Dictionary:
	# Helper function to return machine state
	return machine_states.get(machine_id, {})

func clear_machine_data(machine_id: String):
	# Check if states are stored, if so DELETE
	if machine_id in machine_states:
		machine_states.erase(machine_id)

func clear_all_machine_data():
	# Machine full clear handling
	machine_states.clear()

func print_all_machine_states():
	# Pretty print
	print("=== ALL MACHINE STATES ===")
	if machine_states.is_empty():
		print("No machine states stored")
	else:
		for machine_id in machine_states:
			print("Machine ID: ", machine_id)
			var data = machine_states[machine_id]
			print("  Type: ", data.get("machine_type", "unknown"))
			print("  Ingredients: ", data.get("current_ingredients", {}))
			print("  Output: ", data.get("output_item", {}))
