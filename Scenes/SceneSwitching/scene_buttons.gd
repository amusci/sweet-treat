extends Control

@onready var storage_button = $StorageButton
@onready var baking_button = $BakingButton
@onready var shop_button = $ShopButton

const bakery := "res://Scenes/Areas/bakery_playground.tscn"
const storage := "res://Scenes/Areas/storage_playground.tscn"
const shop := "res://Scenes/Areas/shop_playground.tscn"

func _ready():
	call_deferred("restore_inventory")
	update_button_states()  # Update buttons when scene loads
	
	# Catch disabled button clicks
	baking_button.gui_input.connect(_on_baking_button_input)
	storage_button.gui_input.connect(_on_storage_button_input)
	shop_button.gui_input.connect(_on_shop_button_input)

func restore_inventory():
	InventoryManager.restore_all_inventory_slots()

func get_current_scene(scene_path: String) -> bool:
	# Helper function to return if we are trying to access the same scene we are in
	var current_scene = get_tree().current_scene.scene_file_path
	return current_scene == scene_path

func update_button_states():
	# Disable the button for the current scene
	if get_current_scene(bakery):
		baking_button.disabled = true
		storage_button.disabled = false
		shop_button.disabled = false
	elif get_current_scene(storage):
		baking_button.disabled = false
		storage_button.disabled = true
		shop_button.disabled = false
	elif get_current_scene(shop):
		baking_button.disabled = false
		storage_button.disabled = false
		shop_button.disabled = true

# Disabled button handling
func _on_baking_button_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_current_scene(bakery):
			SfxManager.play_SFX(SfxManager.no)

func _on_storage_button_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_current_scene(storage):
			SfxManager.play_SFX(SfxManager.no)

func _on_shop_button_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_current_scene(shop):
			SfxManager.play_SFX(SfxManager.no)

# Connected buttons
func _on_baking_button_pressed():
	if InventorySlot.buttons_disabled == true:
		return
	InventoryManager.save_all_inventory_slots()
	get_tree().change_scene_to_file(bakery)

func _on_storage_button_pressed():
	if InventorySlot.buttons_disabled == true:
		return
	InventoryManager.save_all_inventory_slots()
	get_tree().change_scene_to_file(storage)
	
func _on_shop_button_pressed():
	if InventorySlot.buttons_disabled == true:
		return
	InventoryManager.save_all_inventory_slots()
	get_tree().change_scene_to_file(shop)
