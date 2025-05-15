extends Button

var tween: Tween
var inventory: Node
var player: Node
var hotbar: Node

func _ready() -> void:
	inventory = find_parent("InvUi")
	player = find_parent("Player")
	hotbar = player.find_child("HotbarUi")
	pressed.connect(close)

func close():
	tween = inventory.get_tree().create_tween()
	tween.tween_property(inventory, "scale", Vector2(0, 0), 0.1)
	await tween.finished
	inventory.visible = false
	hotbar.visible = true
