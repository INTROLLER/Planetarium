extends VBoxContainer

@export var first_time := true

func _ready() -> void:
	for node in get_children():
		node.visible = false
