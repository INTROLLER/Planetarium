extends GridContainer  # This script extends GridContainer to arrange item slots in a grid layout

# Preload the item slot scene so we can instantiate new slots dynamically
var item_slot_scene = load("res://inventory/item_slot.tscn")

func _ready() -> void:
    # Called when this GridContainer enters the scene tree
    
    # Set the pivot offset to center child nodes (e.g., for scaling/rotating around their center)
    pivot_offset = Vector2(13.0, 13.0)

func add(item):
    # Adds a new item slot to the grid for the given item

    # Instantiate a fresh ItemSlot from the preloaded scene
    var item_slot = item_slot_scene.instantiate()

    # Assign the item data to the slot so it knows which item it represents
    item_slot.item = item

    # Update the slot's Texture node to display the item's icon
    item_slot.find_child("Texture").texture = item.data.texture

    # Add the configured slot as a child of this GridContainer
    add_child(item_slot)
