extends Button


func _ready() -> void:
	pressed.connect(close)

func close():
	get_parent().get_parent().get_parent().get_parent().get_parent().visible = false
