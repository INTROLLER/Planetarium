extends Button

var stylebox_def = preload("res://inventory/hotbar/hotbar_slot_default.tres")

var tooltip: Node
var player: Node
var hotbar_container: Node

func _ready() -> void:
	tooltip = find_parent("HotbarTooltip")
	player = find_parent("Player")
	hotbar_container = player.find_child("HotbarContainer")
	pressed.connect(close)
	
func close():
	var slots = hotbar_container.get_children()
	for slot in slots:
		slot.focused = false
		slot.get_child(0).add_theme_stylebox_override("panel", stylebox_def)
	if tooltip.visible:
		tooltip.visible = false
