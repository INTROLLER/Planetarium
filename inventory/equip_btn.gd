extends Button

@export var item: Item

@onready var player = find_parent("Player")

func _ready() -> void:
	pressed.connect(click)
	
func click():
	if !item: return
	if item.equiped == false:
		equip()
	else:
		unequip()
	print(player.loadout.items)
	
	
func unequip():
	item.equiped = false
	find_child("Label").text = "Equip"
	player.loadout.unequip(item)
	player.upd_loadout()
	
	
func equip():
	item.equiped = true
	find_child("Label").text = "Unequip"
	player.loadout.equip(item)
	player.upd_loadout()
