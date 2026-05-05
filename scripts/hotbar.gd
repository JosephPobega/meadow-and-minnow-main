extends Control

@onready var slots = $HBoxContainer.get_children()


func update_hotbar(hotbar_array: Array):
	for i in range(slots.size()):
		var slot = slots[i]

		if i < hotbar_array.size() and hotbar_array[i] != null:
			slot.set_item(hotbar_array[i])
		else:
			slot.clear()
