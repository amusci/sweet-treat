extends Panel

@export var ingredient : Ingredient = null:
	set(value):
		ingredient = value
		
		
		if value == null:
			$Icon.texture = null
			$Amount.text = ""
			return
		
		$Icon.texture = value.icon
		

@export var amount := 0:
	set(value):
		amount = value
		$Amount.text = str(value)
		if amount <= 0:
			ingredient = null

func set_amount(value : int):
	amount = value
	
func add_amount(value : int):
	amount += value
	
func _can_drop_data(_at_position, data):
	if "ingredient" in data:
		#return is_instance_of(data.ingredient, Ingredient)
		return is_instance_of(data.ingredient, Ingredient) and data != self

	return false
	
func _drop_data(_at_position, data):
	var temp = ingredient
	ingredient = data.ingredient
	data.ingredient = temp

	temp = amount
	amount = data.amount
	data.amount = temp
	
func _get_drag_data(_at_position):
	if ingredient:
		var preview_texture = TextureRect.new()
		
		preview_texture.texture = ingredient.icon
		preview_texture.size = Vector2(16,16)
		preview_texture.position = -Vector2(8,8)
		
		var preview = Control.new()
		preview.add_child(preview_texture)
		set_drag_preview(preview)
		
	return self
