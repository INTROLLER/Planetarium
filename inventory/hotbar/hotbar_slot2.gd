extends PanelContainer  # This script extends PanelContainer to provide a clickable, stylized slot for the hotbar

# Preload the default and focused stylebox resources for changing the slot's appearance
var stylebox_def = preload("res://inventory/hotbar/hotbar_slot_default.tres")
var stylebox_foc = preload("res://inventory/hotbar/hotbar_slot_focused.tres")

# References to various nodes we'll need at runtime
var player: Node            # The Player node (to access loadout and tooltip)
var parent: Node            # The parent slot node (this PanelContainer is a child of the slot)
var tooltip: Node           # The HotbarTooltip node used to display item info

# Constants for positioning the tooltip
var height_offset = 5       # A small vertical offset so the tooltip doesn't overlap the slot
var tooltip_height: int     # Cached height of the tooltip, determined at runtime

func _ready():
    # Called when this PanelContainer enters the scene tree

    parent = get_parent()
    # 'parent' is the HotbarSlot node that this PanelContainer is part of

    player = find_parent("Player")
    # Locate the Player node in the ancestor chain

    tooltip = player.find_child("HotbarTooltip")
    # Find the HotbarTooltip node under Player (used to show item details)

    tooltip_height = tooltip.size.y
    # Cache the tooltip's height so we can position it correctly whenever it's shown

func _gui_input(event: InputEvent) -> void:
    # Handles mouse input events on this slot

    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
        # Only respond to left-click presses

        if parent.focused:
            # If this slot is already focused, un-focus it
            add_theme_stylebox_override("panel", stylebox_def)
            # Revert this PanelContainer's stylebox to the default look

            tooltip.visible = false
            # Hide the tooltip since the slot is no longer focused

            parent.focused = false
            # Update the slot's 'focused' state

            return
            # Early exit: we've handled the un-focus case

        # If we reach here, this slot is not currently focused, so we’re about to focus it.
        # First, unfocus all other slots in the hotbar:

        var slots = find_parent("HotbarContainer").get_children()
        # Find the HotbarContainer that holds all slots, then get its child nodes (each slot)

        for slot in slots:
            slot.focused = false
            # Mark each slot as unfocused

            slot.get_child(0).add_theme_stylebox_override("panel", stylebox_def)
            # Reset the visual style of each slot’s PanelContainer (child index 0) to default

        # Next, if this slot has no item assigned, simply hide the tooltip and return:
        if !parent.item:
            if tooltip.visible:
                tooltip.visible = false
            return

        # If there is an item in this slot, proceed to focus it:

        parent.focused = true
        # Mark this slot as focused

        tooltip.item = parent.item
        # Assign the item data to the tooltip so it knows what to display

        add_theme_stylebox_override("panel", stylebox_foc)
        # Change this PanelContainer’s stylebox to the "focused" visual asset

        # Position the tooltip slightly above this slot:
        tooltip.position.x = global_position.x - 13
        # Align the tooltip's X position to match the slot (adjusted by 13 pixels left for centering)

        tooltip.position.y = global_position.y - tooltip_height - height_offset
        # Set the tooltip's Y position to be just above the slot, accounting for its height and an offset

        if !tooltip.visible:
            tooltip.visible = true
        # Make the tooltip visible if it isn’t already

        tooltip.find_child("Title").text = parent.item.data.name
        # Update the tooltip’s title label to show the name of the item in this slot