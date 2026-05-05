extends Control

@onready var icon = $Icon
@onready var count_label = $Count

func set_item(item: Dictionary):
	icon.texture = load("res://items/icons/%s.png" % item["name"])
	count_label.text = str(item["count"])
	count_label.visible = item["count"] > 1

func clear():
	icon.texture = null
	count_label.text = ""
	count_label.visible = false
