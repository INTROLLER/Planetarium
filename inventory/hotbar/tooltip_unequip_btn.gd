extends Button

var player: Node
var tooltip: Node
var item: Item
var hotbar_container: Node

func _ready() -> void:
	player = find_parent("Player")
	tooltip = find_parent("HotbarTooltip")
	hotbar_container = player.find_child("HotbarContainer")
	pressed.connect(unequip)
	
func unequip():
	item = tooltip.item
	item.equiped = false
	player.loadout.unequip(item)
	player.loadout.sort()
	hotbar_container.load_hotbar()
	player.upd_loadout()
	tooltip.visible = false
