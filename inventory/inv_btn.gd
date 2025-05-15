extends Control

var offset = 5

func _ready() -> void:
	position.x += offset
	position.y -= offset
