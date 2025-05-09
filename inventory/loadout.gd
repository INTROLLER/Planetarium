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
