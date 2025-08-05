extends CanvasLayer
signal on_transition_finished
@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready():
	# Make sure color rect is not visible at start and to connect animation finished signals
	if color_rect != null:
		color_rect.visible = false
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE # NO MOUSE INPUTS PLEASE
	if animation_player != null:
		animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(animation_name):
	# Animation finished handling (Make sure to come back to this with more animations
	if animation_name == "fade_to_black":
		on_transition_finished.emit()
		animation_player.play("fade_to_normal")
	elif animation_name == "fade_to_normal":
		color_rect.visible = false

func transition():
	# If color rect exists, make sure to show it
	if color_rect != null:
		color_rect.visible = true
		animation_player.play("fade_to_black")
