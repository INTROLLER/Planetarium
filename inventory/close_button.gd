extends Button


func _ready() -> void:
	pressed.connect(close)

func close():
	find_parent("InvUi").visible = false
