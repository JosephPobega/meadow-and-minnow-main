extends Area2D

@export var item_name := "Seeds"
@export var count := 1
@export var tool_script := preload("res://scripts/seed_tool.gd")

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		return

	body.add_to_hotbar({
		"name": item_name,
		"tool": tool_script.new(),
		"count": count
	})

	queue_free()
