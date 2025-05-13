extends Button

var tween: Tween

@onready var inventory = find_parent("InvUi")

func _ready() -> void:
	pressed.connect(close)

func close():
	tween = inventory.get_tree().create_tween()
	tween.tween_property(inventory, "position", Vector2(68.5, -148.0), 0.1)
	await tween.finished
	inventory.visible = false
