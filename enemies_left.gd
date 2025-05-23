extends Label  # This script extends the Label node to display the count of enemies killed

# Reference to the World node, which emits signals when enemies are killed or new waves start
var world: World

func _ready() -> void:
    # Called when this Label node enters the scene tree

    world = find_parent("World")
    # Locate the nearest ancestor node of type "World" to track game state

    # Connect the world's "enemy_killed" signal to our update() method
    world.enemy_killed.connect(update)

    # Connect the world's "new_wave" signal to our update() method as well
    world.new_wave.connect(update)

func update(_notify = false):
    # This function is called whenever an enemy is killed or a new wave begins
    # (The _notify parameter is unused but allows connection-compatible signatures.)

    text = str(world.killed_enemies)
    # Update this Label's text to show the current number of killed enemies, converting it to a string