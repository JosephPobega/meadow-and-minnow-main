extends Area2D

var item_name := "Jalapeno"

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.add_to_hotbar({
			"name": item_name,
			"tool": null,   
			"count": 1
		})
		queue_free()
