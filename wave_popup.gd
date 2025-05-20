extends PanelContainer

var world: World
var tween: Tween
var confetti: Node

var released_pos: Vector2 = Vector2(141.0, 7.0)

func _ready() -> void:
	world = find_parent("World")
	confetti = get_node("Confetti")
	world.new_wave.connect(appear)
	pivot_offset = size / 2.0

func appear(notify):
	if not notify: return
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	await tween.finished
	confetti.emitting = true

	await get_tree().create_timer(2.0).timeout

	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.1)
