extends Button

var tween: Tween
var inventory: Node
var player: Node
var hotbar: Node
var player_stats_ui: Node

func _ready() -> void:
	inventory = find_parent("InvUi")
	player = find_parent("Player")
	hotbar = player.find_child("HotbarUi")
	player_stats_ui = player.find_child("PlayerStatsUi")
	pressed.connect(close)

func close():
	tween = inventory.get_tree().create_tween()
	tween.tween_property(inventory, "scale", Vector2(0, 0), 0.1)
	await tween.finished
	inventory.visible = false
	hotbar.visible = true
	player_stats_ui.visible = true
	var tween2 = player_stats_ui.get_tree().create_tween()
	tween2.tween_property(player_stats_ui, "position", Vector2(0, 0), 0.1)
	var tween3 = hotbar.get_tree().create_tween()
	tween3.tween_property(hotbar, "position", Vector2(200.0, 197.0), 0.1)