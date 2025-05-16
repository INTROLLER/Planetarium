extends PanelContainer

var stylebox_def = preload("res://inventory/inv_slot_default.tres")
var stylebox_foc = preload("res://inventory/inv_slot_focused.tres")

@onready var parent = get_parent()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		size = Vector2(22.0, 22.0)
		var player = find_parent("Player")
		var invUi = find_parent("InvUi")
		invUi.find_child("Title").text = get_parent().item.data.name
		invUi.find_child("Texture").texture = get_parent().item.data.texture
		invUi.find_child("Damage").text = str(int(get_parent().item.data.damage))
		invUi.find_child("Health").text = str(int(get_parent().item.data.health))
		invUi.find_child("Rarity").text = get_parent().item.data.rarity
		invUi.find_child("RarityOut").text = get_parent().item.data.rarity
		invUi.find_child("EquipBtn").item = parent.item
		invUi.find_child("DelBtn").item = parent.item
		if parent.item.equiped:
			invUi.find_child("EquipBtn").find_child("Label").text = "Unequip"
		else:
			invUi.find_child("EquipBtn").find_child("Label").text = "Equip"
		invUi.find_child("EquipBtn").upd_visuals()
		var slots = find_parent("InvUi").find_child("InvContainer").get_children()
		for slot in slots:
			slot.focused = false
			slot.get_child(0).add_theme_stylebox_override("panel", stylebox_def)
		parent.focused = true
		add_theme_stylebox_override("panel", stylebox_foc)
