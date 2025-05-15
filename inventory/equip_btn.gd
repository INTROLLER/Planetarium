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
	upd_visuals()
	player.loadout.sort()
	player.upd_loadout()
	player.find_child("HotbarContainer").load_hotbar()
	
func unequip():
	item.equiped = false
	find_child("Label").text = "Equip"
	player.loadout.unequip(item)
	
func equip():
	item.equiped = true
	find_child("Label").text = "Unequip"
	player.loadout.equip(item)
	
func upd_visuals():
	if item.equiped == true:
		get_node("Label").label_settings.outline_color = "#503100"
		add_theme_stylebox_override("normal", create_stylebox("#ff9b00"))
		add_theme_stylebox_override("hover", create_stylebox("#ffb037"))
		add_theme_stylebox_override("pressed", create_stylebox("#f09200"))
	else:
		get_node("Label").label_settings.outline_color = "#004800"
		add_theme_stylebox_override("normal", create_stylebox("#39ea39"))
		add_theme_stylebox_override("hover", create_stylebox("#3cff3c"))
		add_theme_stylebox_override("pressed", create_stylebox("#31df31"))

func create_stylebox(color: String):
	var new_stylebox = StyleBoxFlat.new()
	new_stylebox.bg_color = color
	new_stylebox.set_corner_radius_all(3)
	return new_stylebox
