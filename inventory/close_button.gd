extends Button  # This script extends a Button node to handle closing the inventory UI and showing related UI elements

# Tween reference used for animating UI transitions
var tween: Tween

# Node references for UI elements and player
var inventory: Node        # The inventory UI node (InvUi)
var player: Node           # The Player node in the scene tree
var hotbar: Node           # The player's hotbar UI
var player_stats_ui: Node  # The UI displaying player stats

func _ready() -> void:
    # Called when this Button enters the scene tree
    
    # Find the parent node named "InvUi" to get the inventory UI
    inventory = find_parent("InvUi")
    
    # Find the Player node by walking up the ancestor chain
    player = find_parent("Player")
    
    # From the Player node, get the child "HotbarUi" (hotbar UI)
    hotbar = player.find_child("HotbarUi")
    
    # From the Player node, get the child "PlayerStatsUi" (player stats UI)
    player_stats_ui = player.find_child("PlayerStatsUi")
    
    # Connect the Button's `pressed` signal to the close() function
    pressed.connect(close)

func close():
    # Called when the button is pressed; performs UI transitions to close inventory
    
    # Create a tween on the SceneTree to animate the inventory scaling down
    tween = inventory.get_tree().create_tween()
    
    # Animate the inventory’s scale property from its current size to Vector2(0, 0) over 0.1 seconds
    tween.tween_property(inventory, "scale", Vector2(0, 0), 0.1)
    
    # Wait until the tween finishes before proceeding
    await tween.finished
    
    # Once the inventory is scaled down, hide it
    inventory.visible = false
    
    # Show the hotbar UI again
    hotbar.visible = true
    
    # Show the player stats UI as well
    player_stats_ui.visible = true
    
    # Create a second tween to animate the player stats UI into position
    var tween2 = player_stats_ui.get_tree().create_tween()
    # Move the player stats UI to (0, 0) over 0.1 seconds
    tween2.tween_property(player_stats_ui, "position", Vector2(0, 0), 0.1)
    
    # Create a third tween to animate the hotbar UI into its desired position
    var tween3 = hotbar.get_tree().create_tween()
    # Move the hotbar UI to (200.0, 197.0) over 0.1 seconds
    tween3.tween_property(hotbar, "position", Vector2(200.0, 197.0), 0.1)