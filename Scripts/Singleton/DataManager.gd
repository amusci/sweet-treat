extends Node

var dry_ingredients: Dictionary = {} # String -> Ingredient (Dry Storage)
var wet_ingredients: Dictionary = {} # String -> Ingredient (Fridge)
var inbetween_recipes: Dictionary = {} # String -> Ingredient 
var finished_recipes: Dictionary = {} # String -> Recipe

const DRY_INGREDIENTS_PATH = "res://Resources/IngredientResources/dryIngredientResources/"
const WET_INGREDIENTS_PATH = "res://Resources/IngredientResources/"
const FINISHED_RECIPES_PATH = "res://Resources/RecipeResources/FinishedRecipeResources/"
const INBETWEEN_RECIPES_PATH = "res://Resources/RecipeResources/InbetweenRecipeResources/"

signal data_loaded

func _ready():
	load_all_data()
	
func load_all_data():
	load_dry_ingredients()
	load_wet_ingredients()
	load_inbetween_recipes()
	load_finished_recipes()
	data_loaded.emit()
	print("DataManager loaded: ", dry_ingredients.size(), " dry ingredients ", wet_ingredients.size(), " wet ingredients ",inbetween_recipes.size(), " inbetween recipes ", finished_recipes.size(), " finished recipes ")

func load_dry_ingredients():
	var dir = DirAccess.open(DRY_INGREDIENTS_PATH)
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		print("Found file: ", file_name)
		
		if file_name.ends_with(".tres"):
			var full_path = DRY_INGREDIENTS_PATH + file_name
			print("Loading ingredient from: ", full_path)
			
			var ingredient = load(full_path) as Ingredient
			if ingredient:
				var id = file_name.get_basename()  # Remove .tres extension
				dry_ingredients[id] = dry_ingredients
				print("Successfully loaded ingredient: ", id, " - ", ingredient.title)
			else:
				print("ERROR: Failed to load ingredient from: ", full_path)
		
		file_name = dir.get_next()
	
	print("Finished loading ingredients. Total: ", dry_ingredients.size())
	
	
		
	
func load_wet_ingredients():
	pass

func load_inbetween_recipes():
	pass

func load_finished_recipes():
	pass
