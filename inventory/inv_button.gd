extends Button

@onready var inventory = find_parent("Player").find_child("InvUi")

func _ready() -> void:
	pressed.connect(toggle)

func toggle():
	if inventory.visible:
		inventory.visible = false
	else:
		inventory.visible = true
