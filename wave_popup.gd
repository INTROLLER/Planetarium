extends PanelContainer

var world: World
var tween: Tween

var released_pos: Vector2 = Vector2(141.0, 7.0)

func _ready() -> void:
	world = find_parent("World")
	world.new_wave.connect(notify)
	pivot_offset = size / 2.0

func notify():
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	await tween.finished

	await get_tree().create_timer(2.0).timeout

	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.1)