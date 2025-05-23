extends ProgressBar  # This script extends a ProgressBar to represent the player's health visually

# Reference to the player node and tween animation
var player: Player
var tween: Tween

func _ready() -> void:
    # Called when the ProgressBar node enters the scene tree

    # Get the parent node that is assumed to be of type Player
    player = find_parent("Player")
    
    # Connect the custom signal 'health_changed' from the Player to the update() function
    player.health_changed.connect(update)

func update(health):
    # This function updates the ProgressBar's value based on the new health value

    # Set the maximum value to the player's max health
    max_value = player.max_health

    # Kill any existing tween to prevent overlapping animations
    if tween:
        tween.kill()

    # Create a new tween to animate the ProgressBar smoothly to the new health value
    tween = get_tree().create_tween()
    tween.tween_property(self, "value", health, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)