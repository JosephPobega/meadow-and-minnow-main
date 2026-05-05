extends Control

@onready var grid = $GridContainer
var is_open := false
var extra_inventory_ref: Array = []

func open(extra_inv: Array):
	extra_inventory_ref = extra_inv
	is_open = true
	visible = true
	update_menu()

func close():
	is_open = false
	visible = false

func toggle(extra_inv: Array):
	if is_open:
		close()
	else:
		open(extra_inv)

func update_menu():
	# 1. DELETE everything instantly
	for c in grid.get_children():
		c.free() # Removes the node from memory right now

	# 2. RESET the grid math
	grid.columns = 6 # Set your 6 columns
	grid.queue_sort() # Forces the GridContainer to recalculate all positions

	# 3. BUILD the 18 slots (3 rows of 6)
	for i in range(18):
		var slot = preload("res://tscn/Slot.tscn").instantiate()
		grid.add_child(slot)

		# 4. FILL with items if available
		if i < extra_inventory_ref.size():
			var item = extra_inventory_ref[i]
			if item != null:
				slot.set_item(item, 1)
