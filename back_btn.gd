extends Button  # This script extends a Button node to handle returning from the settings menu to the regular menu

# References to the relevant menu nodes
var reg_menu: Node       # Reference to the RegularMenu node
var settings_menu: Node  # Reference to the SettingsMenu node

func _ready() -> void:
    # Called when this Button enters the scene tree

    settings_menu = find_parent("SettingsMenu")
    # Find the nearest ancestor node named "SettingsMenu" and store it

    reg_menu = find_parent("MenuContainer").find_child("RegularMenu")
    # Find the parent node named "MenuContainer", then find its child "RegularMenu" and store it

    pressed.connect(back)
    # Connect this Button's "pressed" signal to the back() function

func back():
    # Called when the button is pressed; switches visibility between menus

    reg_menu.visible = true
    # Show the regular menu

    settings_menu.visible = false
    # Hide the settings menu