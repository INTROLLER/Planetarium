extends ProgressBar

var player: Player
var tween: Tween

func _ready() -> void:
	player = find_parent("Player")
	player.health_changed.connect(update)

func update(health):
	max_value = player.max_health
	if tween:
		tween.kill()

	tween = get_tree().create_tween()
	tween.tween_property(self, "value", health, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)