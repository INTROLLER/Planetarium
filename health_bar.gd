extends ProgressBar

var player: Player
var tween: Tween

func _ready() -> void:
	player = find_parent("Player")
	max_value = player.health
	value = player.health
	player.health_changed.connect(update_value)

func update_value(health):
	if tween:
		tween.kill()

	tween = get_tree().create_tween()
	tween.tween_property(self, "value", health, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)