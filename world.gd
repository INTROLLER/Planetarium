extends Node2D

var enemy_scene = load("res://enemy.tscn")

@export var spawn_enemies := false
@export var active_enemies: Array[Enemy]
@export var max_enemy_count := 5
@export var spawn_radius := 200.0 # distance around player
@export var spawn_interval := 0 # seconds between spawns
@export var player: Player

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
	var new_enemy = enemy_scene.instantiate()
	new_enemy.data = load("res://enemies/earth.tres")

	# Random angle and distance around the player
	var angle = randf() * TAU
	var distance = randf_range(spawn_radius * 0.5, spawn_radius)
	var offset = Vector2(cos(angle), sin(angle)) * distance

	new_enemy.position = player.position + offset

	add_child(new_enemy)
	active_enemies.append(new_enemy)
