extends Node

var dry_ingredients: Dictionary = {} # String -> Ingredient (Dry Storage)
var wet_ingredients: Dictionary = {} # String -> Ingredient (Fridge)
var inbetween_recipes: Dictionary = {} # String -> Ingredient 
var finished_recipes: Dictionary = {} # String -> Recipe

const DRY_INGREDIENTS_PATH = "res://Resources/IngredientResources/dryIngredientResources/"
const WET_INGREDIENTS_PATH = "res://Resources/IngredientResources/wetIngredientResources/"
const INBETWEEN_RECIPES_PATH = "res://Resources/RecipeResources/InbetweenRecipeResources/"
const FINISHED_RECIPES_PATH = "res://Resources/RecipeResources/FinishedRecipeResources/"

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
			print("Loading dry ingredient from: ", full_path)
			
			var ingredient = load(full_path) as Ingredient
			if ingredient:
				var id = file_name.get_basename()  # Remove .tres extension
				dry_ingredients[id] = dry_ingredients
				print("Successfully loaded dry ingredient: ", id, " - ", ingredient.title)
			else:
				print("ERROR: Failed to load dry ingredient from: ", full_path)
		
		file_name = dir.get_next()
	
	print("Finished loading dry ingredients. Total: ", dry_ingredients.size())
	
	
		
	
func load_wet_ingredients():
	var dir = DirAccess.open(WET_INGREDIENTS_PATH)
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		print("Found file: ", file_name)
		
		if file_name.ends_with(".tres"):
			var full_path = WET_INGREDIENTS_PATH + file_name
			print("Loading wet ingredient from: ", full_path)
			
			var ingredient = load(full_path) as Ingredient
			if ingredient:
				var id = file_name.get_basename()  # Remove .tres extension
				wet_ingredients[id] = wet_ingredients
				print("Successfully loaded wet ingredient: ", id, " - ", ingredient.title)
			else:
				print("ERROR: Failed to load wet ingredient from: ", full_path)
		
		file_name = dir.get_next()
	
	print("Finished loading wet ingredients. Total: ", wet_ingredients.size())

func load_inbetween_recipes():
	
	var dir = DirAccess.open(INBETWEEN_RECIPES_PATH)
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		print("Found file: ", file_name)
		
		if file_name.ends_with(".tres"):
			var full_path = INBETWEEN_RECIPES_PATH + file_name
			print("Loading inbetween recipes from: ", full_path)
			
			var recipe = load(full_path) as Recipe
			if recipe:
				var id = file_name.get_basename()  # Remove .tres extension
				inbetween_recipes[id] = inbetween_recipes
				print("Successfully loaded inbetween recipe: ", id, " - ", recipe.title)
			else:
				print("ERROR: Failed to load inbetween recipe from: ", full_path)
		
		file_name = dir.get_next()
	
	print("Finished loading inbetween recipe. Total: ", inbetween_recipes.size())

func load_finished_recipes():
	
	var dir = DirAccess.open(FINISHED_RECIPES_PATH)
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		print("Found file: ", file_name)
		
		if file_name.ends_with(".tres"):
			var full_path = FINISHED_RECIPES_PATH + file_name
			print("Loading finished recipes from: ", full_path)
			
			var recipe = load(full_path) as Recipe
			if recipe:
				var id = file_name.get_basename()  # Remove .tres extension
				finished_recipes[id] = finished_recipes
				print("Successfully loaded finished recipe: ", id, " - ", recipe.title)
			else:
				print("ERROR: Failed to load finished recipe from: ", full_path)
		
		file_name = dir.get_next()
	
	print("Finished loading finished recipe. Total: ", finished_recipes.size())
