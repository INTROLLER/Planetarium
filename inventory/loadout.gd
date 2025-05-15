extends Resource

class_name Loadout

@export var items : Array[Item]

func equip(item):
	for i in items.size():
		var slot = items[i]
		if slot == null:
			items[i] = item
			return

func unequip(item):
	for i in items.size():
		var slot = items[i]
		if slot == item:
			items[i] = null
			return


func sort():
	for i in range(0, items.size() - 1):
		var slot = items[i]
		var next_slot = items[i + 1]
		if slot == null and next_slot != null:
			items[i] = next_slot
			items[i + 1] = null
