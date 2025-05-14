extends Button

var tween: Tween

@onready var inventory = find_parent("InvUi")

func _ready() -> void:
	pressed.connect(close)

func close():
	tween = inventory.get_tree().create_tween()
	tween.tween_property(inventory, "scale", Vector2(0, 0), 0.1)
	await tween.finished
	inventory.visible = false
