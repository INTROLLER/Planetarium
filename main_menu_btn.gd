extends Button  # This script extends a Button node to handle opening the main menu from the death screen

# Reference to the player node
var player: Player

func _ready() -> void:
    # Called when the node enters the scene tree

    # Find the Player node in the parent hierarchy
    player = find_parent("Player")

    # Connect this button’s press signal to the open_main_menu function
    pressed.connect(open_main_menu)

func open_main_menu():
    # This function is triggered when the button is pressed
    # It handles transitioning from the death screen to the main menu

    # Start a tween to fade out the death screen by animating its alpha to 0 over 0.5 seconds
    var tween = player.death_screen.get_tree().create_tween()
    tween.tween_property(player.death_screen, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)

    # Wait until the fade-out tween finishes
    await tween.finished

    # Hide the death screen after fading out
    player.death_screen.visible = false

    # Show the main menu and start a tween to fade it in by animating its alpha to 1 over 0.5 seconds
    player.main_menu.visible = true
    var tween2 = player.main_menu.get_tree().create_tween()
    tween2.tween_property(player.main_menu, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)