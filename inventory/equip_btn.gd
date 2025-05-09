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
		add_theme_stylebox_override("normal", create_stylebox("#ff6400"))
		add_theme_stylebox_override("hover", create_stylebox("#ff7f2c"))
		add_theme_stylebox_override("pressed", create_stylebox("#d65400"))
	else:
		add_theme_stylebox_override("normal", create_stylebox("#00ed00"))
		add_theme_stylebox_override("hover", create_stylebox("#68ff61"))
		add_theme_stylebox_override("pressed", create_stylebox("#14c015"))

func create_stylebox(color: String):
	var new_stylebox = StyleBoxFlat.new()
	new_stylebox.bg_color = color
	new_stylebox.set_corner_radius_all(3)
	return new_stylebox
