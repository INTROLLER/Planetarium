extends Button

var reg_menu: Node
var settings_menu: Node

func _ready() -> void:
	settings_menu = find_parent("SettingsMenu")
	reg_menu = find_parent("MenuContainer").find_child("RegularMenu")
	pressed.connect(back)

func back():
	reg_menu.visible = true
	settings_menu.visible = false
