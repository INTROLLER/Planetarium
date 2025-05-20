extends ProgressBar

var world: World
var tween: Tween

func _ready() -> void:
	world = find_parent("World")
	world.new_wave.connect(update)
	world.enemy_killed.connect(update)

func update(_notify = false):
	max_value = world.max_enemy_count
	if tween:
		tween.kill()

	tween = get_tree().create_tween()
	tween.tween_property(self, "value", world.killed_enemies, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
