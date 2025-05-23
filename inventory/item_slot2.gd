extends PanelContainer  # This script extends PanelContainer to represent a single inventory slot with click handling

# Preload default and focused styleboxes for inventory slot visuals
var stylebox_def = preload("res://inventory/inv_slot_default.tres")
var stylebox_foc = preload("res://inventory/inv_slot_focused.tres")

# Mapping from rarity strings to gradient textures for display in the inventory UI
var rarity_map = {
    "common": {
        "gradient": load("res://inventory/gradient_common.tres")
    },
    "uncommon": {
        "gradient": load("res://inventory/gradient_uncommon.tres")
    },
    "rare": {
        "gradient": load("res://inventory/gradient_rare.tres")
    },
    "epic": {
        "gradient": load("res://inventory/gradient_epic.tres")
    },
    "mythic": {
        "gradient": load("res://inventory/gradient_mythic.tres")
    },
    "legendary": {
        "gradient": load("res://inventory/gradient_legendary.tres")
    }
}

# Cache a reference to this slot's parent node (the actual ItemSlot) once the node is ready
@onready var parent = get_parent()

func _gui_input(event: InputEvent) -> void:
    # Called automatically when the user interacts with this PanelContainer via GUI input
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
        # Only respond to left-click presses

        # Optionally resize this slot to give immediate visual feedback on click
        size = Vector2(22.0, 22.0)

        # Find the Player node in the ancestor chain to access player-specific data if needed
        var player = find_parent("Player")
        # Find the inventory UI (InvUi) in the ancestor chain; this is where we display item details
        var invUi = find_parent("InvUi")

        # Update the inventory UI labels and textures based on the item in this slot:
        invUi.find_child("Title").text = get_parent().item.data.name
        # Set the title label to the item's name

        invUi.find_child("Texture").texture = get_parent().item.data.texture
        # Show the item's icon in the inventory UI

        invUi.find_child("Damage").text = str(int(get_parent().item.data.damage))
        # Convert the item's damage to an integer string and display it

        invUi.find_child("Rarity").text = get_parent().item.data.rarity
        # Display the rarity text (e.g., "Common", "Rare")

        # Set the gradient texture for the rarity indicator based on the item's rarity
        invUi.find_child("Rarity").find_child("Gradient").texture = rarity_map[get_parent().item.data.rarity.to_lower()]["gradient"]

        invUi.find_child("RarityOut").text = get_parent().item.data.rarity
        # Update an additional rarity label ("RarityOut") to match the item's rarity

        # Assign this slot's item to the Equip and Delete buttons so they know which item to operate on
        invUi.find_child("EquipBtn").item = parent.item
        invUi.find_child("DelBtn").item = parent.item

        # If the item is already equipped, label the equip button as "Unequip", otherwise "Equip"
        if parent.item.equiped:
            invUi.find_child("EquipBtn").find_child("Label").text = "Unequip"
        else:
            invUi.find_child("EquipBtn").find_child("Label").text = "Equip"

        # Refresh the visual style of the Equip button to match its new state
        invUi.find_child("EquipBtn").upd_visuals()

        # Un-focus all other slots in the inventory UI so only this one appears selected:
        var slots = find_parent("InvUi").find_child("InvContainer").get_children()
        for slot in slots:
            slot.focused = false
            slot.get_child(0).add_theme_stylebox_override("panel", stylebox_def)
            # Reset each slot's PanelContainer (child index 0) to the default style

        # Mark this slot as focused
        parent.focused = true
        # Override this PanelContainer's style to the focused stylebox
        add_theme_stylebox_override("panel", stylebox_foc)