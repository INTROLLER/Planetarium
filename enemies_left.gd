extends Label

var world: World

func _ready() -> void:
	world = find_parent("World")
	world.enemy_killed.connect(update)
	world.new_wave.connect(update)

func update(_notify = false):
	text = str(world.killed_enemies)
