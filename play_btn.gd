extends Button

var world: World

func _ready() -> void:
	world = find_parent("World")
	pressed.connect(play)

func play():
	world.start_game()
