extends Label

var world: World

func _ready() -> void:
	world = find_parent("World")
	world.new_wave.connect(update)

func update(_notify = false):
	text = str(world.max_enemy_count)