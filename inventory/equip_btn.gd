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
	upd_visuals()
	
func equip():
	item.equiped = true
	find_child("Label").text = "Unequip"
	player.loadout.equip(item)
	player.upd_loadout()
	upd_visuals()
	
func upd_visuals():
	if item.equiped == true:
		get_node("Label").label_settings.outline_color = "#1d2a3b"
		add_theme_stylebox_override("normal", create_stylebox("#6aa7de"))
		add_theme_stylebox_override("hover", create_stylebox("#7bc1ff"))
		add_theme_stylebox_override("pressed", create_stylebox("#558ec1"))
	else:
		get_node("Label").label_settings.outline_color = "#004800"
		add_theme_stylebox_override("normal", create_stylebox("#45de45"))
		add_theme_stylebox_override("hover", create_stylebox("#45ff45"))
		add_theme_stylebox_override("pressed", create_stylebox("#35bb35"))

func create_stylebox(color: String):
	var new_stylebox = StyleBoxFlat.new()
	new_stylebox.bg_color = color
	new_stylebox.set_corner_radius_all(3)
	return new_stylebox
