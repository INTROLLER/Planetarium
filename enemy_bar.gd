extends ProgressBar  # This script extends ProgressBar to visually show wave progress based on killed enemies

var world: World    # Reference to the World node, which provides enemy/wave data
var tween: Tween    # Reference to a Tween used for smooth value transitions

func _ready() -> void:
    # Called when this ProgressBar enters the scene tree

    world = find_parent("World")
    # Locate the nearest ancestor node of type World to access game state

    world.new_wave.connect(update)
    # Connect the World’s "new_wave" signal to our update() method,
    # so when a new wave starts, we can reset/update the bar’s max value

    world.enemy_killed.connect(update)
    # Connect the World’s "enemy_killed" signal to our update() method,
    # so whenever an enemy dies, we animate the progress bar toward the new count

func update(_notify = false):
    # Called whenever a new wave starts or an enemy is killed
    # (_notify is unused but required to match the signal signature)

    max_value = world.max_enemy_count
    # Update the ProgressBar’s maximum to match the total enemies in the current wave

    if tween:
        tween.kill()
        # If there’s an existing Tween running, kill it before starting a new one

    tween = get_tree().create_tween()
    # Create a new Tween on the SceneTree for the smooth value animation

    tween.tween_property(
        self,
        "value",
        world.killed_enemies,
        0.3
    ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    # Animate the ProgressBar’s "value" property to the current number of killed enemies
    # over 0.3 seconds, using a sine transition with ease-out for a smooth effect