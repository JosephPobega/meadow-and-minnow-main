extends Control

@onready var slots: Array = $HBoxContainer.get_children()
@onready var selector: Control = $Selector

# ---------------------------------------------------------
# UPDATE HOTBAR ICONS
# ---------------------------------------------------------
func update_hotbar(hotbar_array: Array):
	for i in range(slots.size()):
		var slot: Control = slots[i]

		if i < hotbar_array.size() and hotbar_array[i] != null:
			slot.set_item(hotbar_array[i])
		else:
			slot.clear()


# ---------------------------------------------------------
# CENTER SELECTOR (DELAYED FOR UI LAYOUT)
# ---------------------------------------------------------
func center_selector_later(index: int):
	await get_tree().process_frame
	update_selector(index)


# ---------------------------------------------------------
# MOVE SELECTOR TO SLOT
# ---------------------------------------------------------
func update_selector(index: int):
	var slot: Control = slots[index]

	var rect: Rect2 = slot.get_global_rect()
	var slot_center: Vector2 = rect.position + rect.size * 0.5
	var selector_center: Vector2 = selector.size * 0.5

	# Optional tiny nudge to the right (adjust if needed)
	var offset := Vector2(0, 0)

	selector.global_position = slot_center - selector_center + offset
