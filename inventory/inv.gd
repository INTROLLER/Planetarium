extends Resource  # This script defines a custom Resource for managing an inventory list

# Register this class as “Inv” so it can be used as a resource type in the editor
class_name Inv

# Export an array of Item resources so they can be assigned and viewed in the Inspector
@export var items: Array[Item]

func delete_item(id):
    # Iterate through each item in the inventory
    for item in items:
        # Check if the current item's ID matches the given ID
        if item.id == id:
            # Remove the matching item from the array
            items.erase(item)
            # Optionally, you could break here if IDs are unique:
            # break