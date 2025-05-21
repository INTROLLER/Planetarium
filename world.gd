class_name  World

extends Node2D

signal new_wave()
signal enemy_killed()
signal game_started()

@export var spawn_enemies := false
@export var active_enemies: Array[Enemy]
@export var max_enemy_count := 5
@export var killed_enemies := 0
@export var spawn_radius := 400.0 # distance around player
@export var spawn_interval := 0 # seconds between spawns
@export var player: Player
@export var wave := 0

var enemy_scene = load("res://enemy.tscn")
var current_wave_config = {}
var _spawn_timer := 0.0
var enemies_spawned_in_wave := 0

func _physics_process(delta: float) -> void:
	if not spawn_enemies or player == null:
		return

	_spawn_timer += delta

	# Only spawn if we haven't hit the wave spawn limit
	if enemies_spawned_in_wave < max_enemy_count and _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		spawn_enemy()

	# Clean up dead enemies
	active_enemies = active_enemies.filter(func(enemy):
		return is_instance_valid(enemy)
	)

	# When all enemies are dead and we spawned all for this wave, move to next wave
	if enemies_spawned_in_wave >= max_enemy_count and active_enemies.is_empty():
		set_wave(wave + 1, true)

func get_wave_config():
	var config := {}

	# 1. Max enemies scales with wave (capped at 50)
	config["max_enemies"] = clamp(5 + wave * 2, 5, 50)

	# 2. Spawn interval decreases with wave (min 0.3s)
	config["interval"] = max(2.0 - wave * 0.1, 0.3)

	# 3. Enemy type probabilities
	var enemy_chances = {
		"earth": clamp(1.0 - wave * 0.05, 0.2, 1.0), # decreases from 1.0 to 0.2
		#"fire": clamp(0.0 + wave * 0.05, 0.0, 0.8),  # increases from 0.0 to 0.8
		#"ice":  clamp((wave - 5) * 0.05, 0.0, 0.5)   # unlocks at wave 5
	}

	# Normalize
	var total_weight = 0.0
	for weight in enemy_chances.values():
		total_weight += weight
	for k in enemy_chances.keys():
		enemy_chances[k] /= total_weight

	config["enemy_chances"] = enemy_chances

	return config

func set_wave(wave_num: int, notify := false) -> void:
	wave = wave_num
	enemies_spawned_in_wave = 0
	killed_enemies = 0

	current_wave_config = get_wave_config()

	max_enemy_count = current_wave_config["max_enemies"]
	spawn_interval = current_wave_config["interval"]

	new_wave.emit(notify)

func spawn_enemy() -> void:
	var max_attempts := 10
	for i in max_attempts:
		var angle = randf() * TAU
		var distance = randf_range(spawn_radius * 0.5, spawn_radius)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		var spawn_position = player.position + offset

		# Check overlap
		var is_overlapping := false
		for enemy in active_enemies:
			if is_instance_valid(enemy) and enemy.position.distance_to(spawn_position) < enemy.find_child("Hitbox").shape.radius:
				is_overlapping = true
				break

		if not is_overlapping:
			var new_enemy = enemy_scene.instantiate()
			var enemy_chances: Dictionary = current_wave_config.get("enemy_chances", {})
			var roll := randf()
			var cumulative := 0.0
			var enemy_type := "earth"

			for e_type in enemy_chances.keys():
				cumulative += enemy_chances[e_type]
				if roll <= cumulative:
					enemy_type = e_type
					break

			new_enemy.data = load("res://enemies/%s.tres" % enemy_type)

			new_enemy.scale = Vector2(0.0, 0.0)
			new_enemy.position = spawn_position
			add_child(new_enemy)
			active_enemies.append(new_enemy)

			enemies_spawned_in_wave += 1  # ✅ Count it

			var tween = new_enemy.get_tree().create_tween()
			tween.tween_property(new_enemy, "scale", Vector2(1.0, 1.0), 0.3)
			return

	print("Failed to spawn enemy: no space found after %d attempts" % max_attempts)

func stop_game(_window = null):
	spawn_enemies = false
	for enemy in active_enemies:
		enemy.queue_free()
	active_enemies.clear()
	_window.visible = true
	var tween = _window.get_child(0).get_tree().create_tween()
	tween.tween_property(_window.get_child(0), "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	player.playing = false

func start_game(_window = null):
	current_wave_config = get_wave_config()
	set_wave(1)
	var tween = _window.get_child(0).get_tree().create_tween()
	tween.tween_property(_window.get_child(0), "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
	await tween.finished
	_window.visible = false
	spawn_enemies = true
	player.playing = true
	game_started.emit()
