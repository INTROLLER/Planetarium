extends Label

var world: World

func _ready() -> void:
	world = find_parent("World")
	text = str(world.wave)
	world.new_wave.connect(update)

func update(wave_num: int) -> void:
	text = str(wave_num)