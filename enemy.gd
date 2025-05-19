class_name Enemy

extends Area2D

var sprite: Node
var hitbox: Node
var world: World
var tween: Tween
var player: Player

@export var data: EnemyData
@export var health: float
@export var damage: float

var loot_scene = load("res://inventory/loot/loot.tscn")
var vanish_particle_scene = load("res://vanish_particle.tscn")
var velocity := Vector2.ZERO
var friction := 1000.0
var knockback_force := 300.0
var knockback_threshold := 5.0
var move_speed := 80.0

func _ready() -> void:
	world = find_parent("World")
	player = world.get_node("Player")
	health = data.health
	damage = data.damage
	sprite = $Sprite
	hitbox = $Hitbox
	area_entered.connect(get_hit)
	body_entered.connect(hit)
	sprite.texture = data.texture
	hitbox.shape.radius = (sprite.texture.get_size().x / 2.0) * sprite.scale[0]
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	separate_from_enemies()

	if velocity.length() > knockback_threshold:
		global_position += velocity * delta
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity = Vector2.ZERO

		if player:
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * move_speed * delta


func get_hit(area):
	if area is Orbitable:
		health -= area.item.data.damage
		flash_damage()
		check_death()
			
func hit(body):
	if body is Player:
		body.health -= damage
		health -= body.body_damage

		# Apply knockback away from player
		var direction = (global_position - body.global_position).normalized()
		velocity += direction * knockback_force
		flash_damage()
		body.flash_damage()
		body.health_changed.emit(body.health)
		check_death()
		if body.health <= 0:
			world.game_over()

func check_death():
	if health <= 0:
		var particle = vanish_particle_scene.instantiate()
		particle.emitting = true
		particle.global_position = global_position
		world.add_child(particle)
		drop_loot()
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property(sprite, "scale", Vector2(0.0, 0.0), 0.1)
		await tween.finished
		queue_free()

func flash_damage():
	# Set to a red-tinted color (you can adjust alpha too if needed)
	modulate = Color(3.314, 1.0, 1.0)  # Light red flash

	# Animate back to normal (white means "no tint")
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1.4, 1.4, 1.4), 0.3)

func drop_loot():
	var spawned_loot = []

	# Determine which items will spawn
	for drop in data.drops:
		if randf() < drop.probability:
			spawned_loot.append(drop)

	if spawned_loot.is_empty():
		return

	# Grid layout setup
	var total = spawned_loot.size()
	var cols = int(ceil(sqrt(total)))
	var spacing = 27
	var rows = int(ceil(float(total) / cols))

	for i in range(total):
		var row = int(i / cols)
		var col = i % cols

		# Determine how many items are in this row
		var items_in_row = cols
		if row == rows - 1 and total % cols != 0:
			items_in_row = total % cols

		# Calculate start_x based on current row width
		var row_width = (items_in_row - 1) * spacing
		var start_x = -row_width / 2.0
		var start_y = -((rows - 1) * spacing) / 2.0

		# Prevent overflow on last row
		if row == rows - 1 and col >= items_in_row:
			continue

		var offset = Vector2(start_x + col * spacing, start_y + row * spacing)

		var loot = loot_scene.instantiate()
		loot.item_data = spawned_loot[i].data
		loot.global_position = global_position + offset
		find_parent("World").add_child(loot)
		
func separate_from_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var separation_force = Vector2.ZERO
	
	for other in enemies:
		if other == self:
			continue
		
		var distance = global_position.distance_to(other.global_position)
		var min_distance = (hitbox.shape.radius + other.hitbox.shape.radius)

		if distance < min_distance and distance > 0:
			var push_direction = (global_position - other.global_position).normalized()
			var overlap = min_distance - distance
			
			# Apply minimum push force to avoid stuck behavior
			var push_strength = max(overlap * 10, 200)  # 100 is minimum force value; adjust as needed
			separation_force += push_direction * push_strength

	velocity += separation_force
