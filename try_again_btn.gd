extends Button

var world: World
var player: Player

func _ready() -> void:
	world = find_parent("World")
	player = find_parent("Player")
	pressed.connect(play)

func play():
	world.start_game(player.death_screen)