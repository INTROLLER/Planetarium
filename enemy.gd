extends Area2D

class_name Enemy

var loot_scene = load("res://inventory/drops/loot.tscn")
var vanish_particle_scene = load("res://vanish_particle.tscn")

var sprite: Node
var hitbox: Node
var world: Node
var tween: Tween

@export var data: EnemyData
@export var health: float
@export var damage: float

func _ready() -> void:
	world = find_parent("World")
	health = data.health
	damage = data.damage
	sprite = $Sprite
	hitbox = $Hitbox
	area_entered.connect(take_damage)
	sprite.texture = data.texture
	hitbox.shape.radius = (sprite.texture.get_size().x / 2.0) * sprite.scale[0]
	
func take_damage(area):
	print("lol")
	if area is Orbitable:
		health -= area.item.data.damage
		flash_damage()
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
	modulate = Color(3.8, 1.0, 1.0)  # Light red flash

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
