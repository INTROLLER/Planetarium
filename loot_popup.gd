extends Control  # This script extends a UI Control node to display a temporary loot pickup indicator

# References to internal nodes and objects
var timer: Timer                  # Timer to delay hiding the loot UI
var player: Player                # Reference to the Player node
var texture_disp: TextureRect     # UI element to show the loot item's texture
var tween: Tween                  # Tween to animate the loot popup in/out

func _ready() -> void:
    # Called when the node enters the scene tree

    # Find the Player node up the scene tree
    player = find_parent("Player")

    # Find the TextureRect child that displays the item's icon
    texture_disp = find_child("Texture")

    # Connect the custom signal 'loot_collected' from the Player to this node's set_loot function
    player.loot_collected.connect(set_loot)

    # Adjust the pivot to center the popup for smooth scaling
    pivot_offset = get_child(0).size / -2.0

func set_loot(item_data):
    # Called when the player collects loot; displays the item's texture temporarily

    # Set the texture of the UI to the item's texture
    texture_disp.texture = item_data.texture

    # Create a timer if it doesn't already exist
    if timer == null:
        timer = Timer.new()
        add_child(timer)
        timer.wait_time = 0.5  # Display duration

    # Cancel any active tween before starting a new one
    if tween:
        tween.kill()
    
    # Create a new tween to scale the loot popup in (visible)
    tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

    # Connect the timer's timeout signal to a function that hides the popup
    timer.timeout.connect(_on_timer_timeout)
    timer.start()  # Start the countdown

func _on_timer_timeout():
    # Called when the timer finishes after showing the loot popup

    # Kill any active tween before starting the hide animation
    tween.kill()

    # Animate the scale back to zero (invisible)
    tween = create_tween()
    tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.1)

    # Wait for the animation to finish before proceeding
    await tween.finished