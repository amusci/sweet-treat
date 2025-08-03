extends PathFollow2D

@export var speed: float = .25

var direction := 1

func _process(delta):
	progress_ratio += speed * delta * direction
	print(progress_ratio)
	
	var path_length = get_parent().curve.get_baked_length()
	
	
	if progress_ratio >= 1:
		progress_ratio = 1
		direction = -1
		
	elif progress_ratio <= 0:
		progress_ratio = 0
		direction = 1
		
	
