class_name World
extends Node2D

# Signals to communicate game events
signal new_wave()
signal enemy_killed()
signal game_started()

# Exported properties for tuning in the editor
@export var spawn_enemies := false
@export var active_enemies: Array[Enemy]
@export var max_enemy_count := 5
@export var killed_enemies := 0
@export var spawn_radius := 400.0  # Distance around the player where enemies can spawn
@export var spawn_interval := 0  # Seconds between enemy spawns
@export var player: Player
@export var wave := 0

# Internal resources and state
var enemy_scene = load("res://enemy.tscn")
var current_wave_config = {}
var _spawn_timer := 0.0
var enemies_spawned_in_wave := 0

# Called every frame (physics step)
func _physics_process(delta: float) -> void:
	if not spawn_enemies or player == null:
		return

	_spawn_timer += delta

	# Check if it's time to spawn a new enemy and limit total per wave
	if enemies_spawned_in_wave < max_enemy_count and _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		spawn_enemy()

	# Clean up invalid (dead) enemies
	active_enemies = active_enemies.filter(func(enemy):
		return is_instance_valid(enemy)
	)

	# If all wave enemies are dead, start the next wave
	if enemies_spawned_in_wave >= max_enemy_count and active_enemies.is_empty():
		set_wave(wave + 1, true)

# Generate configuration for the current wave
func get_wave_config():
	var config := {}

	# 1. Increase number of enemies per wave, capped at 50
	config["max_enemies"] = clamp(5 + wave * 2, 5, 50)

	# 2. Decrease spawn interval over time, minimum 0.3s
	config["interval"] = max(2.0 - wave * 0.1, 0.3)

	# 3. Adjust spawn chances for different enemy types
	var enemy_chances = {
		"asteroid": clamp(1.0 - wave * 0.05, 0.2, 1.0),
		"ice_planet": clamp(0.0 + wave * 0.05, 0.0, 0.8),
		"sun": clamp((wave - 5) * 0.05, 0.0, 0.5)
	}

	# Normalize probabilities to total 1.0
	var total_weight = 0.0
	for weight in enemy_chances.values():
		total_weight += weight
	for k in enemy_chances.keys():
		enemy_chances[k] /= total_weight

	config["enemy_chances"] = enemy_chances

	return config

# Set wave number and optionally emit a new_wave signal
func set_wave(wave_num: int, notify := false) -> void:
	wave = wave_num
	enemies_spawned_in_wave = 0
	killed_enemies = 0

	current_wave_config = get_wave_config()
	max_enemy_count = current_wave_config["max_enemies"]
	spawn_interval = current_wave_config["interval"]

	new_wave.emit(notify)

# Attempts to spawn a new enemy at a valid location
func spawn_enemy() -> void:
	var max_attempts := 10
	for i in max_attempts:
		# Random position around player
		var angle = randf() * TAU
		var distance = randf_range(spawn_radius * 0.5, spawn_radius)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		var spawn_position = player.position + offset

		# Check for overlap with other enemies
		var is_overlapping := false
		for enemy in active_enemies:
			if is_instance_valid(enemy) and enemy.position.distance_to(spawn_position) < enemy.find_child("Hitbox").shape.radius:
				is_overlapping = true
				break

		# If valid spawn found, create the enemy
		if not is_overlapping:
			var new_enemy = enemy_scene.instantiate()

			# Determine enemy type using weighted probabilities
			var enemy_chances: Dictionary = current_wave_config.get("enemy_chances", {})
			var roll := randf()
			var cumulative := 0.0
			var enemy_type := "earth"  # fallback type

			for e_type in enemy_chances.keys():
				cumulative += enemy_chances[e_type]
				if roll <= cumulative:
					enemy_type = e_type
					break

			# Set enemy data and position
			new_enemy.data = load("res://enemies/%s.tres" % enemy_type)
			new_enemy.scale = Vector2(0.0, 0.0)
			new_enemy.position = spawn_position
			add_child(new_enemy)

			active_enemies.append(new_enemy)
			enemies_spawned_in_wave += 1

			# Animate scale-in
			var tween = new_enemy.get_tree().create_tween()
			tween.tween_property(new_enemy, "scale", Vector2(1.0, 1.0), 0.3)
			return

	# If all spawn attempts failed
	print("Failed to spawn enemy: no space found after %d attempts" % max_attempts)

# Stops the game and shows the main menu
func stop_game(menu = null):
	spawn_enemies = false

	# Remove all enemies
	for enemy in active_enemies:
		enemy.queue_free()
	active_enemies.clear()

	# Show menu with fade-in effect
	menu.visible = true
	var tween = menu.get_tree().create_tween()
	tween.tween_property(menu, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)

	player.playing = false

# Starts the game from the menu
func start_game(menu = null):
	current_wave_config = get_wave_config()
	set_wave(1)

	# Hide menu with fade-out animation
	var tween = menu.get_tree().create_tween()
	tween.tween_property(menu, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
	await tween.finished
	menu.visible = false

	spawn_enemies = true
	player.playing = true
	game_started.emit()
