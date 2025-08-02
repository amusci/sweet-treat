extends Control

@onready var money_label = $MoneyLabel

func _ready():
	money_label.text = str(Money.money)
	Money.connect("change_money", _on_money_changed)
	
func _on_money_changed(new_amount): #has _ before because it is connected to a signal
	money_label.text = str(new_amount) #changes the text in the label to new amount value in the Money script
