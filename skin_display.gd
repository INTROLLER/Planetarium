extends TextureRect

var player: Player

func _ready() -> void:
	player = find_parent("Player")
	texture = player.find_child("Sprite").texture