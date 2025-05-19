extends Button

var player: Node
var hotbar_container: Node
var inv_container: Node

@export var item: Item

func _ready() -> void:
	player = find_parent("Player")
	hotbar_container = player.find_child("HotbarContainer")
	inv_container = find_parent("InvUi").find_child("InvContainer")
	pressed.connect(delete)
	
func delete():
	if !item: return
	if item.equiped:
		player.loadout.unequip(item)
		player.loadout.sort()
		player.upd_loadout()
		hotbar_container.load_hotbar()
	player.inv.delete_item(item.id)
	var slots = inv_container.get_children()
	for slot in slots:
		if slot.item.id == item.id:
			inv_container.remove_child(slot)
