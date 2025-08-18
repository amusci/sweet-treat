class_name Recipe
extends Resource

@export var title: String
@export var icon: Texture2D
@export var description: String
@export var category: String # if it is an in between (cookie batter) or just finished cookie
@export var ingredients: Array[RecipeRequirement] = []
@export var tool_required: String
@export var tool_required_icon: Texture2D
@export var sell_price: float = 0.0
@export var time_to_make: float = 10.0
