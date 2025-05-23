extends Button  # This script extends a Button node to handle unequipping items via the hotbar tooltip

# References to nodes and data we'll use at runtime
var player: Node             # The Player node, which contains loadout data
var tooltip: Node            # The HotbarTooltip node, which holds the currently hovered/focused item
var item: Item               # A temporary reference to the Item being unequipped
var hotbar_container: Node   # The HotbarContainer node, which manages the hotbar UI

func _ready() -> void:
    # Called when this Button enters the scene tree

    player = find_parent("Player")
    # Find the Player node by walking up the ancestor chain

    tooltip = find_parent("HotbarTooltip")
    # Find the HotbarTooltip node by walking up; this tooltip holds the item we're working with

    hotbar_container = player.find_child("HotbarContainer")
    # From the Player node, find the HotbarContainer which manages all hotbar slots

    pressed.connect(unequip)
    # Connect this Button's "pressed" signal to the unequip() function,
    # so clicking the button will trigger item unequip logic

func unequip():
    # Called when the Button is pressed; handles removing the item from the hotbar and loadout

    item = tooltip.item
    # Retrieve the currently displayed item in the tooltip

    item.equiped = false
    # Mark the item as no longer equipped

    player.loadout.unequip(item)
    # Tell the player's loadout to unequip this item, removing it from any equipped list

    player.loadout.sort()
    # Sort the remaining items in the loadout (e.g., to keep inventory order consistent)

    hotbar_container.load_hotbar()
    # Refresh the hotbar UI by reloading all slots, reflecting that the item is no longer equipped

    player.upd_loadout()
    # Call a method on Player to update any internal state/UI related to the loadout

    tooltip.visible = false
    # Hide the tooltip since the item is no longer on the hotbar