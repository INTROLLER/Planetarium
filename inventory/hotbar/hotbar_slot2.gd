extends PanelContainer

var stylebox_def = preload("res://inventory/hotbar/hotbar_slot_default.tres")
var stylebox_foc = preload("res://inventory/hotbar/hotbar_slot_focused.tres")

var player: Node
var parent: Node
var tooltip: Node

var height_offset = 5
var tooltip_height: int

func _ready():
	parent = get_parent()
	player = find_parent("Player")
	tooltip = player.find_child("HotbarTooltip")
	tooltip_height = tooltip.size.y

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if parent.focused:
			add_theme_stylebox_override("panel", stylebox_def)
			tooltip.visible = false
			parent.focused = false
			return
		var slots = find_parent("HotbarContainer").get_children()
		for slot in slots:
			slot.focused = false
			slot.get_child(0).add_theme_stylebox_override("panel", stylebox_def)
		if !parent.item:
			if tooltip.visible:
				tooltip.visible = false
			return
		parent.focused = true
		tooltip.item = parent.item
		add_theme_stylebox_override("panel", stylebox_foc)
		tooltip.position.x = global_position.x - 13
		tooltip.position.y = global_position.y - tooltip_height - height_offset
		if !tooltip.visible:
			tooltip.visible = true
		tooltip.find_child("Title").text = parent.item.data.name
