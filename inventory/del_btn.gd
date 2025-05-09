extends Button

@export var item: Item

func _ready() -> void:
	pressed.connect(delete)
	
func delete():
	if !item: return
	find_parent("Player").inv.delete_item(item.id)
	var slots = find_parent("InvUi").find_child("InvContainer").get_children()
	for slot in slots:
		if slot.item.id == item.id:
			find_parent("InvUi").find_child("InvContainer").remove_child(slot)
