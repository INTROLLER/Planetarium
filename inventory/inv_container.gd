extends GridContainer

var item_slot_scene = load("res://inventory/item_slot.tscn")

func _ready() -> void:
	pivot_offset = Vector2(13.0, 13.0)

func add(item):
	var item_slot = item_slot_scene.instantiate()
	item_slot.item = item
	item_slot.find_child("Texture").texture = item.data.texture
	add_child(item_slot)
