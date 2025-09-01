extends Control

@onready var baking_soda_output = $BakingSodaOutputSlot
@onready var egg_output = $EggOutputSlot
@onready var flour_output = $FlourOutputSlot
@onready var sea_salt_output = $SeaSaltOutputSlot
@onready var sugar_output = $SugarOutputSlot
@onready var vanilla_extract_output = $VanillaOutputSlot
@onready var butter_output = $ButterOutputSlot

# Resources will be loaded from DataManager
var baking_soda_resource: Resource
var egg_resource: Resource  
var flour_resource: Resource
var sea_salt_resource: Resource
var sugar_resource: Resource
var vanilla_extract_resource: Resource
var butter_resource: Resource

func _ready():
	# Wait for DataManager to load all resources
	if DataManager.data_loaded.is_connected(_on_data_loaded):
		return
	DataManager.data_loaded.connect(_on_data_loaded)
	
	# If data is already loaded, load resources immediately
	if DataManager.dry_ingredients.size() > 0 or DataManager.wet_ingredients.size() > 0:
		_on_data_loaded()

func _on_data_loaded():
	# Load ingredient resources from DataManager
	baking_soda_resource = _get_ingredient("baking_soda")
	egg_resource = _get_ingredient("egg")
	flour_resource = _get_ingredient("flour") 
	sea_salt_resource = _get_ingredient("sea_salt")
	sugar_resource = _get_ingredient("sugar")
	vanilla_extract_resource = _get_ingredient("vanilla_extract")
	butter_resource = _get_ingredient("butter")
	
	print("Shop resources loaded from DataManager")

func _get_ingredient(ingredient_id: String) -> Resource:
	# Check dry ingredients first, then wet ingredients
	if DataManager.dry_ingredients.has(ingredient_id):
		return DataManager.dry_ingredients[ingredient_id]
	elif DataManager.wet_ingredients.has(ingredient_id):
		return DataManager.wet_ingredients[ingredient_id]
	else:
		print("Warning: Ingredient '", ingredient_id, "' not found in DataManager")
		return null

func _on_baking_soda_button_pressed():
	SfxManager.play_SFX(SfxManager.buy)
	purchase_item(baking_soda_resource, baking_soda_output, "Baking Soda")

func _on_egg_button_pressed():
	SfxManager.play_SFX(SfxManager.buy)
	purchase_item(egg_resource, egg_output, "Egg")

func _on_flour_button_pressed():
	SfxManager.play_SFX(SfxManager.buy)
	purchase_item(flour_resource, flour_output, "Flour")

func _on_sea_salt_button_pressed():
	SfxManager.play_SFX(SfxManager.buy)
	purchase_item(sea_salt_resource, sea_salt_output, "Sea Salt")

func _on_sugar_button_pressed():
	SfxManager.play_SFX(SfxManager.buy)
	purchase_item(sugar_resource, sugar_output, "Sugar")

func _on_butter_button_pressed():
	SfxManager.play_SFX(SfxManager.buy)
	purchase_item(butter_resource, butter_output, "Butter")

func _on_vanilla_button_pressed():
	SfxManager.play_SFX(SfxManager.buy)
	purchase_item(vanilla_extract_resource, vanilla_extract_output, "Vanilla Extract")

func purchase_item(item_resource: Resource, output_slot: ShopOutput, item_name: String):
	# Item purchasing 
	if item_resource == null:
		print("Error: No resource defined for ", item_name)
		return
	
	if output_slot == null:
		print("Error: No output slot found for ", item_name)
		return
	
	# Check if we have enough money
	var item_price = item_resource.price
	if Money.money >= item_price:
		# Spend dat money
		Money.spend_money(item_price)
		
		# Add item to output slot
		output_slot.add_purchased_item(item_resource, 1)
	else:
		print("Not enough money! Need $", item_price, " but only have $", Money.money)
