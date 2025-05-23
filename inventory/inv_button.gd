extends Button  # This script extends Button to toggle the inventory UI and adjust related UI elements

# Preload the default stylebox for hotbar slots to reset visuals when opening inventory
var stylebox_def = preload("res://inventory/hotbar/hotbar_slot_default.tres")

# References to nodes and a Tween for animating UI transitions
var tween: Tween
var inventory: Node        # The inventory UI (InvUi) under Player
var player: Node           # Reference to the Player node
var hotbar: Node           # The Hotbar UI (HotbarUi) under Player
var hotbar_tooltip: Node   # The HotbarTooltip node under Player
var player_stats_ui: Node  # The PlayerStatsUi node under Player

func _ready() -> void:
    # Called when this Button enters the scene tree

    player = find_parent("Player")
    # Find the Player node by walking up the ancestor chain

    inventory = player.find_child("InvUi")
    # Get the InvUi node from the Player (inventory panel)

    hotbar = player.find_child("HotbarUi")
    # Get the HotbarUi node from the Player

    hotbar_tooltip = player.find_child("HotbarTooltip")
    # Get the HotbarTooltip node from the Player

    player_stats_ui = player.find_child("PlayerStatsUi")
    # Get the PlayerStatsUi node from the Player

    pressed.connect(toggle)
    # Connect this Button's `pressed` signal to the toggle() function

    # Initialize inventory to be scaled down and hidden at start
    inventory.scale = Vector2(0, 0)
    inventory.visible = false

    # Set the pivot offset to the center (so scaling will appear centered)
    inventory.pivot_offset = inventory.size / 2


func toggle():
    # Called when the button is pressed; toggles showing/hiding the inventory

    tween = inventory.get_tree().create_tween()
    # Create a tween on the SceneTree for animating inventory properties

    if inventory.visible:
        # If inventory is currently visible, hide it with a scale-down animation

        tween.tween_property(inventory, "scale", Vector2(0, 0), 0.1)
        # Animate scale from current to (0,0) over 0.1 seconds

        await tween.finished
        # Wait for the scale tween to complete

        inventory.visible = false
        # Once scaled down, actually hide the inventory node

        hotbar.visible = true
        # Show the hotbar UI again

        player_stats_ui.visible = true
        # Show the player stats UI again

        # Animate player stats UI back into its default position
        var tween2 = player_stats_ui.get_tree().create_tween()
        tween2.tween_property(player_stats_ui, "position", Vector2(0, 0), 0.1)

        # Animate hotbar UI back into its default position
        var tween3 = hotbar.get_tree().create_tween()
        tween3.tween_property(hotbar, "position", Vector2(200.0, 197.0), 0.1)

    else:
        # If inventory is currently hidden, show it with an animation and hide other UIs

        var slots = hotbar.get_child(0).get_children()
        # Get the list of hotbar slots (assuming hotbar.get_child(0) returns the container of slots)

        inventory.visible = true
        # Make the inventory node visible

        hotbar_tooltip.visible = false
        # Hide the hotbar tooltip to avoid overlap

        tween.tween_property(inventory, "scale", Vector2(1, 1), 0.1)
        # Animate scale from (0,0) to (1,1) over 0.1 seconds

        # Animate player stats UI off-screen to the left
        var tween2 = player_stats_ui.get_tree().create_tween()
        tween2.tween_property(
            player_stats_ui,
            "position",
            Vector2(-player_stats_ui.get_child(0).size.x, 0),
            0.1
        )

        # Animate hotbar UI downward to make room for inventory
        var tween3 = hotbar.get_tree().create_tween()
        tween3.tween_property(
            hotbar,
            "position",
            Vector2(200.0, 197.0 + hotbar.size.y),
            0.1
        )

        # Reset all hotbar slots to un-focused and default style
        for slot in slots:
            slot.focused = false
            slot.get_child(0).add_theme_stylebox_override("panel", stylebox_def)

        await tween2.finished
        # Wait for the player stats UI to finish its tween before hiding

        player_stats_ui.visible = false
        # Now that player stats UI is off-screen, hide it

        hotbar.visible = false
        # Hide the hotbar UI to fully show the inventory