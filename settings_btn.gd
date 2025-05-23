extends Button

var reg_menu: Node
var settings_menu: Node

func _ready() -> void:
	reg_menu = find_parent("RegularMenu")
	settings_menu = find_parent("MenuContainer").find_child("SettingsMenu")
	pressed.connect(open_settings)

func open_settings():
	reg_menu.visible = false
	settings_menu.visible = true