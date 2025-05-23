extends Button  # This script extends Button to provide equip/unequip functionality for an item

# Exported variable to assign which Item this button controls
@export var item: Item

# On-ready variable to reference the Player node in the scene tree
@onready var player = find_parent("Player")

func _ready() -> void:
    # Called when this Button enters the scene tree
    pressed.connect(click)
    # Connect the button's "pressed" signal to the click() function

func click():
    # Called when the button is pressed; toggles equip state of the item

    var sucess: bool
    if !item:
        return
    # If no item is assigned, do nothing

    if item.equiped == false:
        # If the item is not currently equipped, attempt to equip it
        sucess = equip()
    else:
        # If the item is already equipped, attempt to unequip it
        sucess = unequip()

    if sucess:
        # If equip/unequip operation succeeded:
        upd_visuals()
        # Update the button's appearance based on the new state

        player.loadout.sort()
        # Sort the player's loadout (to maintain consistent inventory order)

        player.upd_loadout()
        # Update any UI or internal state related to the loadout

        player.find_child("HotbarContainer").load_hotbar()
        # Reload the hotbar UI so it reflects any changes

func equip():
    # Attempts to equip the item via the player's loadout
    var equiped = player.loadout.equip(item)
    if equiped:
        # If the loadout reports that equipping succeeded:
        item.equiped = true
        # Mark the item's own flag as equipped

        find_child("Label").text = "Unequip"
        # Change the button label to indicate it will unequip next time
    return equiped
    # Return true if equipping succeeded, false otherwise

func unequip():
    # Attempts to unequip the item via the player's loadout
    var unequiped = player.loadout.unequip(item)
    if unequiped:
        # If the loadout reports that unequipping succeeded:
        item.equiped = false
        # Mark the item's own flag as unequipped

        find_child("Label").text = "Equip"
        # Change the button label to indicate it will equip next time
    return unequiped
    # Return true if unequipping succeeded, false otherwise

func upd_visuals():
    # Updates the button's visual style depending on whether the item is equipped
    if item.equiped == true:
        # If the item is equipped:
        get_node("Label").label_settings.outline_color = "#503100"
        # Set the label outline color to a darker tone

        add_theme_stylebox_override("normal", create_stylebox("#ff9b00"))
        # Override the "normal" style to a bright orange

        add_theme_stylebox_override("hover", create_stylebox("#ffb037"))
        # Override the "hover" style to a lighter orange

        add_theme_stylebox_override("pressed", create_stylebox("#f09200"))
        # Override the "pressed" style to a darker orange
    else:
        # If the item is not equipped:
        get_node("Label").label_settings.outline_color = "#004800"
        # Set the label outline color to a dark green

        add_theme_stylebox_override("normal", create_stylebox("#39ea39"))
        # Override the "normal" style to bright green

        add_theme_stylebox_override("hover", create_stylebox("#3cff3c"))
        # Override the "hover" style to a lighter green

        add_theme_stylebox_override("pressed", create_stylebox("#31df31"))
        # Override the "pressed" style to a darker green

func create_stylebox(color: String):
    # Helper function to create a StyleBoxFlat with a given background color

    var new_stylebox = StyleBoxFlat.new()
    # Instantiate a new StyleBoxFlat

    new_stylebox.bg_color = color
    # Set its background color to the provided hex string

    new_stylebox.set_corner_radius_all(3)
    # Give it rounded corners with a radius of 3 pixels

    return new_stylebox
    # Return the configured StyleBoxFlat