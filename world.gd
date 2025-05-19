extends Node2D

var enemy_scene = load("res://enemy.tscn")

@export var spawn_enemies := false
@export var active_enemies: Array[Enemy]
@export var max_enemy_count := 5
@export var spawn_radius := 400.0 # distance around player
@export var spawn_interval := 0 # seconds between spawns
@export var player: Player
@export var wave: int

var _spawn_timer := 0.0

func _ready() -> void:
	player = $Player

func _physics_process(delta: float) -> void:
	if not spawn_enemies or player == null:
		return

	_spawn_timer += delta

	if _spawn_timer >= spawn_interval and active_enemies.size() < max_enemy_count:
		_spawn_timer = 0.0
		spawn_enemy()

	# Cleanup enemies that no longer exist
	active_enemies = active_enemies.filter(func(enemy):
		return is_instance_valid(enemy)
	)

func spawn_enemy() -> void:
	var max_attempts := 10
	for i in max_attempts:
		var angle = randf() * TAU
		var distance = randf_range(spawn_radius * 0.5, spawn_radius)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		var spawn_position = player.position + offset

		# Check for overlap with existing enemies
		var is_overlapping := false
		for enemy in active_enemies:
			if is_instance_valid(enemy) and enemy.position.distance_to(spawn_position) < enemy.find_child("Hitbox").shape.radius: # adjust 32 to enemy radius
				is_overlapping = true
				break

		if not is_overlapping:
			var new_enemy = enemy_scene.instantiate()
			new_enemy.data = load("res://enemies/earth.tres")
			new_enemy.scale = Vector2(0.0, 0.0)
			new_enemy.position = spawn_position
			add_child(new_enemy)
			active_enemies.append(new_enemy)
			var tween = new_enemy.get_tree().create_tween()
			tween.tween_property(new_enemy, "scale", Vector2(1.0, 1.0), 0.3)
			return

	print("Failed to spawn enemy: no space found after %d attempts" % max_attempts)
