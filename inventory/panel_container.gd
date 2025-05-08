extends PanelContainer

@onready var index = get_parent().index

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var player = find_parent("Player")
		var invUi = find_parent("InvUI")
		invUi.find_child("Title").text = player.inv.items[index].name
		invUi.find_child("Texture").texture = player.inv.items[index].texture
		invUi.find_child("Damage").text = str(player.inv.items[index].damage)
		invUi.find_child("Health").text = str(player.inv.items[index].health)
		invUi.find_child("Rarity").text = player.inv.items[index].rarity
