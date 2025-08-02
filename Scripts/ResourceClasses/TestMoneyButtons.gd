extends Control

@onready var add_money_button = $AddMoney
@onready var spend_money_button =$SpendMoney

func _ready():
	add_money_button.pressed.connect(_on_add_pressed)
	spend_money_button.pressed.connect(_on_spend_pressed)
	
func _on_add_pressed():
	Money.add_money(50)
	
func _on_spend_pressed():
	Money.spend_money(50)
