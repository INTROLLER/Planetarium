extends Button  # This script extends the Button node to act as a “close” button for the hotbar tooltip

# Preload the default stylebox for resetting slot visuals when closing
var stylebox_def = preload("res://inventory/hotbar/hotbar_slot_default.tres")

# References to nodes we’ll need at runtime
var tooltip: Node           # The HotbarTooltip node to hide when closing
var player: Node            # The Player node (for finding the hotbar container)
var hotbar_container: Node  # The node containing all hotbar slots

func _ready() -> void:
    # Called when this Button enters the scene tree

    tooltip = find_parent("HotbarTooltip")
    # Locate the tooltip by walking up the tree (this button is a child of the tooltip)

    player = find_parent("Player")
    # Find the Player node in the ancestor chain

    hotbar_container = player.find_child("HotbarContainer")
    # From the Player node, find the HotbarContainer (which holds all slots)

    pressed.connect(close)
    # Connect this button’s “pressed” signal to the close() function

func close():
    # Called when the button is pressed (i.e., when we want to close/hide the tooltip)

    var slots = hotbar_container.get_children()
    # Get all slot nodes inside the HotbarContainer

    for slot in slots:
        slot.focused = false
        # Mark each slot as not focused

        slot.get_child(0).add_theme_stylebox_override("panel", stylebox_def)
        # Reset the slot’s PanelContainer (child index 0) back to the default stylebox

    if tooltip.visible:
        tooltip.visible = false
        # If the tooltip is currently visible, hide it