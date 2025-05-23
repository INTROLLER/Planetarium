extends Button  # This script extends Button to provide functionality for deleting an item from inventory

# References to nodes that will be set at runtime
var player: Node            # Reference to the Player node (to access loadout and inventory)
var hotbar_container: Node  # Reference to the HotbarContainer node (to refresh the hotbar if needed)
var inv_container: Node     # Reference to the InvContainer node (to remove the UI slot)

# Exported variable to assign which Item this delete button belongs to
@export var item: Item

func _ready() -> void:
    # Called when this Button enters the scene tree

    # Find the Player node by walking up the ancestor chain
    player = find_parent("Player")

    # From the Player node, find the HotbarContainer (so we can reload it if an equipped item is deleted)
    hotbar_container = player.find_child("HotbarContainer")

    # Find the InvUi parent, then locate its child InvContainer (which holds all inventory slots)
    inv_container = find_parent("InvUi").find_child("InvContainer")

    # Connect this button's "pressed" signal to the delete() function
    pressed.connect(delete)

func delete():
    # Called when the delete button is pressed; handles removing the item from both data and UI

    if !item:
        return
    # If there is no assigned item, do nothing

    if item.equiped:
        # If the item is currently equipped, we need to unequip it first

        player.loadout.unequip(item)
        # Remove the item from the player's equipped loadout

        player.loadout.sort()
        # Re-sort the loadout to maintain inventory order

        player.upd_loadout()
        # Update any UI or internal state related to the loadout

        hotbar_container.load_hotbar()
        # Reload the hotbar UI so the deleted (formerly equipped) item no longer appears

    # Remove the item from the player's inventory data
    player.inv.delete_item(item.id)

    # Iterate through all child slot nodes in the inv_container
    var slots = inv_container.get_children()
    for slot in slots:
        if slot.item.id == item.id:
            # If we find the slot whose item ID matches the deleted item
            inv_container.remove_child(slot)
            # Remove that slot from the inventory UI