extends Button

var tween: Tween

@onready var inventory = find_parent("Player").find_child("InvUi")

func _ready() -> void:
	pressed.connect(toggle)
	inventory.scale = Vector2(0, 0)  # Start
	inventory.visible = false
	inventory.pivot_offset = inventory.size / 2

func toggle():
	tween = inventory.get_tree().create_tween()
	if inventory.visible:
		tween.tween_property(inventory, "scale", Vector2(0, 0), 0.1)
		await tween.finished
		inventory.visible = false
	else:
		inventory.visible = true
		tween.tween_property(inventory, "scale", Vector2(1, 1), 0.1)
		print("Lol")
