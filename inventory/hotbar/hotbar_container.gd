extends GridContainer  # This script extends GridContainer to arrange hotbar slots in a grid layout

# Preload the hotbar slot scene to instantiate slots dynamically
var hotbar_slot_scene = preload("res://inventory/hotbar/hotbar_slot.tscn")

# Reference to the player node, where we get the current loadout
var player: Node

func _ready() -> void:
    # Once this node enters the scene tree, find the Player node in its ancestors
    player = find_parent("Player")
    # Populate the hotbar with the player's current items
    load_hotbar()

func load_hotbar():
    # First, clear any existing slots from this GridContainer
    for slot in get_children():
        remove_child(slot)

    # Iterate over each item in the player's loadout
    for item in player.loadout.items:
        # Instantiate a new hotbar slot from the preloaded scene
        var hotbar_slot = hotbar_slot_scene.instantiate()
        # Add the new slot as a child of this GridContainer
        add_child(hotbar_slot)

        # Assign the item to the slot for further logic (e.g., selection, use)
        hotbar_slot.item = item

        # Update the slot's texture: if there's no item, clear the texture; otherwise, show the item's icon
        if item == null:
            hotbar_slot.find_child("Texture").texture = null
        else:
            hotbar_slot.find_child("Texture").texture = item.data.texture
