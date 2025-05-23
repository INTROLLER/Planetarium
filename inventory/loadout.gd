extends Resource  # This script defines a Resource to manage an equipable loadout of items

# Register this class as “Loadout” so it can be used as a custom resource in the Godot editor
class_name Loadout

# Export an array of Item objects so you can assign/load them in the Inspector
@export var items: Array[Item]

func equip(item):
    # Attempts to place the given item into the first empty slot of the loadout.
    # Returns true if the item was equipped successfully, or false if no empty slot was available.

    # Loop over each index in the items array
    for i in items.size():
        if items[i] == null:
            # Found an empty slot—assign the item here
            items[i] = item
            return true  # Successful equip
    return false  # No empty slot found; equip failed

func unequip(item):
    # Searches for the given item in the loadout and removes it by setting that slot to null.
    # Returns true if the item was found and unequipped, or false if it was not in the loadout.

    # Loop over each index in the items array
    for i in items.size():
        var slot = items[i]
        if slot == item:
            # Found the item—clear this slot
            items[i] = null
            return true  # Successful unequip
    return false  # Item was not found in the loadout

func sort():
    # Moves any null (empty) slots toward the end of the array by swapping consecutive entries.
    # This ensures that all equipped items are packed toward the front of the loadout list.

    # Iterate from the first element up to the second-to-last
    for i in range(0, items.size() - 1):
        var slot = items[i]
        var next_slot = items[i + 1]
        if slot == null and next_slot != null:
            # Current slot is empty, but the next slot has an item.
            # Swap them: move the item one slot forward and push the null back.
            items[i] = next_slot
            items[i + 1] = null