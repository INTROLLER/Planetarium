extends GridContainer

var hotbar_slot_scene = preload("res://inventory/hotbar/hotbar_slot.tscn")
var player: Node

func _ready() -> void:
	player = find_parent("Player")
	load_hotbar()

func load_hotbar():
	for slot in get_children():
		remove_child(slot)
	for item in player.loadout.items:
		var hotbar_slot = hotbar_slot_scene.instantiate()
		add_child(hotbar_slot)
		hotbar_slot.item = item
		if item == null:
			hotbar_slot.find_child("Texture").texture = null
		else:
			hotbar_slot.find_child("Texture").texture = item.data.texture
