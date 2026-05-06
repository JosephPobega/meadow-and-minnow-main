extends Area2D

var item_name := "WateringCan"
var tool_script := preload("res://scripts/watering_can.gd")

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.add_to_hotbar({
			"name": item_name,
			"tool": tool_script.new(),
			"count": 1
		})
		queue_free()


func use(player):
	if player.is_using_tool:
		return

	player.is_using_tool = true

	# Directional animation
	var dir: Vector2 = player.last_dir
	if abs(dir.x) > abs(dir.y):
		player.anim.play("water_right" if dir.x > 0 else "water_left")
	else:
		player.anim.play("water_down" if dir.y > 0 else "water_up")

	# Impact frame
	await player.get_tree().create_timer(0.15).timeout

	# Water tile
	var tile_pos: Vector2i = player.get_facing_tile()
	player.water(tile_pos)

	# Wait for animation to finish
	await player.anim.animation_finished

	# Reset
	player.anim.play("idle")
	player.is_using_tool = false
