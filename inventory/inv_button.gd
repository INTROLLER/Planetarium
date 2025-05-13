extends Button

var tween: Tween

@onready var inventory = find_parent("Player").find_child("InvUi")
@onready var def_pos = inventory.position

func _ready() -> void:
	pressed.connect(toggle)
	inventory.position = Vector2(68.5, -148.0)  # Start invisible
	inventory.visible = false

func toggle():
	tween = inventory.get_tree().create_tween()
	if inventory.visible:
		tween.tween_property(inventory, "position", Vector2(68.5, -148.0), 0.1)
		await tween.finished
		inventory.visible = false
	else:
		inventory.visible = true
		tween.tween_property(inventory, "position", def_pos, 0.1)
