extends CanvasLayer

@onready var menu = $Menu
@onready var player = $"../Player"

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("menu"):
		menu.toggle(player.inventory)
