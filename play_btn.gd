extends Button

# References to the game world and player
var world: World
var player: Player

func _ready() -> void:
    # Get references to the World and Player nodes from the scene tree
    world = find_parent("World")
    player = find_parent("Player")

    # Connect the button's pressed signal to the play() function
    pressed.connect(play)

func play():
    # Call the start_game function in the world, passing the player's main menu
    # This typically hides the menu and starts the actual game logic
    world.start_game(player.main_menu)