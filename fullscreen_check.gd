extends CheckButton  # This script extends CheckButton to toggle the game window between fullscreen and windowed modes

# Boolean flag to track the current fullscreen state
var fullscreen := false

func _ready() -> void:
    # Called when this CheckButton enters the scene tree

    # Check the current window mode at startup
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        # If the window is already in fullscreen mode, update our flag and CheckButton state
        fullscreen = true
        button_pressed = true
    # Connect the CheckButton's "pressed" signal to the toggle() function
    pressed.connect(toggle)

func toggle():
    # Called whenever the CheckButton is clicked (toggled)
    if fullscreen:
        # If we are currently in fullscreen, switch to windowed mode
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        button_pressed = false   # Uncheck the CheckButton
        fullscreen = false       # Update the state flag
    else:
        # If we are not in fullscreen, switch to fullscreen mode
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
        button_pressed = true    # Check the CheckButton
        fullscreen = true        # Update the state flag