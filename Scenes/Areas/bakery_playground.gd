extends Node2D

@onready var pause_menu = $PauseMenu
@onready var order_container = $OrderContainer

var not_showing := false

func _ready():
	pause_menu.visible = false

func _process(_delta):
	# If paused hide the order container and set time_scale to 0.0
	if Input.is_action_just_pressed("pause_menu"): # Escape key
		not_showing = !not_showing
		pause_menu.visible = not_showing
		order_container.visible = !not_showing
		Engine.time_scale = 1.0 if !not_showing else 0.0
