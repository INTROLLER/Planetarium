extends Control

var timer: Timer
var player: Player
var texture_disp: TextureRect
var tween: Tween

func _ready() -> void:
	player = find_parent("Player")
	texture_disp = find_child("Texture")
	player.loot_collected.connect(set_loot)
	pivot_offset = get_child(0).size / -2.0

func set_loot(item_data):
	texture_disp.texture = item_data.texture
	if timer == null:
		timer = Timer.new()
		add_child(timer)
		timer.wait_time = 0.5

	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.1)
	await tween.finished
