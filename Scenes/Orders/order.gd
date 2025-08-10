extends VBoxContainer

###TODO: Maybe a button the cancel orders you don't want to do?
######## Needs to show sprite + SPRITE + sPrItE = RECIPE
######## Need to also show previous inbetween recipes.. no clue how to do this...


var progress_bar: ProgressBar
var label: Label
var recipe
var time_left: float
var max_time: float

func setup(order_data):
	# Order setup functionality
	# Need to load these two as they are instantiated
	progress_bar = get_node("ProgressBar") 
	label = get_node("Label")
	# Then set the UI to the data
	recipe = order_data.recipe
	time_left = order_data.time_left
	max_time = recipe.time_to_make
	
	label.text = recipe.title
	progress_bar.max_value = 100.0
	progress_bar.value = 100.0

func _process(delta):
	if time_left > 0:
		time_left -= delta
		# Calculate progress 
		if progress_bar != null:
			progress_bar.value = (time_left / max_time) * 100.0
		
		if time_left <= 0:
			# Order expired
			OrderManager.remove_order(self)
