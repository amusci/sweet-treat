extends Node

var money: int = 0

signal change_money(new_amount)
# creates a signal called change_money

func add_money(amount: int) -> void: # creates add money function
	money += amount
	emit_signal("change_money", money)
	#signals change money to be fired and passes in new money value on line 9
	
func spend_money(amount: int) -> bool: #same as add_money function but is a bool to make sure the player has enough money for the transaction
	if money >= amount:
		money -= money - amount
		emit_signal("change_money", money)
		return true
	return false
	
