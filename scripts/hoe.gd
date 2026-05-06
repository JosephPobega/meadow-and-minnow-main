extends Area2D

var item_name := "Hoe"
var tool_script := preload("res://scripts/hoe.gd")

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
	# Prevent spamming
	if player.is_using_tool:
		return

	player.is_using_tool = true

	# Pick correct animation based on direction
	var dir: Vector2 = player.last_dir
	if abs(dir.x) > abs(dir.y):
		player.anim.play("hoe_right" if dir.x > 0 else "hoe_left")
	else:
		player.anim.play("hoe_down" if dir.y > 0 else "hoe_up")

	# Impact frame timing
	await player.get_tree().create_timer(0.15).timeout

	# Tile interaction
	var tile_pos: Vector2i = player.get_facing_tile()
	if player.can_till(tile_pos):
		player.till(tile_pos)

	# Wait for animation to finish
	await player.anim.animation_finished

	# Reset
	player.anim.play("idle")
	player.is_using_tool = false
