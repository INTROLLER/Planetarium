extends Button

var player: Player

func _ready() -> void:
	player = find_parent("Player")
	pressed.connect(open_main_menu)

func open_main_menu():
	var tween = player.death_screen.get_tree().create_tween()
	tween.tween_property(player.death_screen, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
	await tween.finished
	player.death_screen.visible = false

	player.main_menu.visible = true
	var tween2 = player.main_menu.get_tree().create_tween()
	tween2.tween_property(player.main_menu, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
