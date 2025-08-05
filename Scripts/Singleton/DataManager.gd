extends Node

var dry_ingredients: Dictionary = {} # String -> Ingredient (Dry Storage)
var wet_ingredients: Dictionary = {} # String -> Ingredient (Fridge)
var inbetween_recipes: Dictionary = {} # String -> Recipe
var finished_recipes: Dictionary = {} # String -> Recipe

const DRY_INGREDIENTS_PATH = "res://Resources/IngredientResources/dryIngredientResources/"
const WET_INGREDIENTS_PATH = "res://Resources/IngredientResources/wetIngredientResources/"
const INBETWEEN_RECIPES_PATH = "res://Resources/RecipeResources/InbetweenRecipeResources/"
const FINISHED_RECIPES_PATH = "res://Resources/RecipeResources/FinishedRecipeResources/"

signal data_loaded

func _ready():
	load_all_data()
	
func load_all_data():
	load_resources(DRY_INGREDIENTS_PATH, dry_ingredients, "dry ingredient")
	load_resources(WET_INGREDIENTS_PATH, wet_ingredients, "wet ingredient")
	load_resources(INBETWEEN_RECIPES_PATH, inbetween_recipes, "inbetween recipe")
	load_resources(FINISHED_RECIPES_PATH, finished_recipes, "finished recipe")
	data_loaded.emit() # Let the world know we are ready to rumble
	print("DataManager loaded: ", dry_ingredients.size(), " dry ingredients, ", wet_ingredients.size(), " wet ingredients, ", inbetween_recipes.size(), " inbetween recipes, ", finished_recipes.size(), " finished recipes")

func load_resources(directory_path: String, target_dictionary: Dictionary, resource_type: String):
	# Loads resources specified in load_all_data
	var dir = DirAccess.open(directory_path)
	if dir == null:
		print("ERROR: Could not open directory: ", directory_path)
		return
	
	dir.list_dir_begin() # Start listing all files in directory
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"): # Loop through directory looking for only .tres
			var full_path = directory_path + file_name
			var resource = load(full_path)
			if resource:
				var id = file_name.get_basename()  # Remove .tres extension
				target_dictionary[id] = resource # Adds resource to dictionary
				# print("Successfully loaded ", resource_type, ": ", id, " - ", resource.title)
			else:
				print("ERROR: Failed to load ", resource_type, " from: ", full_path)
		
		file_name = dir.get_next() # Next in line

	print("Finished loading ", resource_type, "s. Total: ", target_dictionary.size())
