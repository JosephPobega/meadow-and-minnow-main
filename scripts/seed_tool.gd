extends Node

var item_name := "Seeds"

func use(player):
	if player.is_using_tool:
		return

	player.is_using_tool = true

	var tile_pos = player.get_facing_tile()

	if player.can_plant(tile_pos):
		player.plant_seed(tile_pos)

	player.is_using_tool = false
