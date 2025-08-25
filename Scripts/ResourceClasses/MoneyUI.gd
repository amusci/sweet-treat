extends Control

@onready var money_label = $MoneyLabel
const game_over = "res://Scenes/Areas/UIScenes/game_over.tscn"

func _ready():
	money_label.text = str(Money.money)
	Money.connect("change_money", _on_money_changed)
	
func _process(_delta):
	if Money.money <= 100:
		MachineManager.clear_all_machine_data()
		InventoryManager.clear_all_inventory_slots()
		get_tree().change_scene_to_file(game_over)
		
	
func _on_money_changed(new_amount): #has _ before because it is connected to a signal
	money_label.text = str(new_amount) #changes the text in the label to new amount value in the Money script
