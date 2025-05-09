extends Resource

class_name Inv

@export var items: Array[Item]


func delete_item(id):
	for item in items:
		if item.id == id:
			items.erase(item)
