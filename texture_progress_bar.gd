extends TextureProgressBar

var player: Player

func _ready() -> void:
	player = find_parent("Player")
	max_value = player.health
	value = player.health
	player.health_changed.connect(update_value)

func update_value(health):
	value = health