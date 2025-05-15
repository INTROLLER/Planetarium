extends Button

var stylebox_def = preload("res://inventory/hotbar/hotbar_slot_default.tres")

var tween: Tween
var inventory: Node
var player: Node
var hotbar: Node
var hotbar_tooltip: Node

func _ready() -> void:
	player = find_parent("Player")
	inventory = player.find_child("InvUi")
	hotbar = player.find_child("HotbarUi")
	hotbar_tooltip = player.find_child("HotbarTooltip")
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
		hotbar.visible = true
	else:
		var slots = hotbar.get_child(0).get_children()
		inventory.visible = true
		hotbar.visible = false
		hotbar_tooltip.visible = false
		tween.tween_property(inventory, "scale", Vector2(1, 1), 0.1)
		for slot in slots:
			slot.focused = false
			slot.get_child(0).add_theme_stylebox_override("panel", stylebox_def)
