extends Label  # This script extends a Label node to display the maximum number of enemies in the current wave

# Reference to the World node
var world: World

func _ready() -> void:
    # Called when the node enters the scene tree

    # Get a reference to the World node from the parent hierarchy
    world = find_parent("World")

    # Connect to the World's "new_wave" signal to update the label whenever a new wave starts
    world.new_wave.connect(update)

func update(_notify = false):
    # Updates the label's text to show the maximum number of enemies in the current wave
    text = str(world.max_enemy_count)
