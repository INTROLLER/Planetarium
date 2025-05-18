extends Area2D

class_name Enemy

var loot_scene = load("res://inventory/drops/loot.tscn")
var vanish_particle_scene = load("res://vanish_particle.tscn")

var sprite: Node
var hitbox: Node
var world: Node

@export var enemy: EnemyData
@export var health: float
@export var damage: float

@onready var tween = get_tree().create_tween()

func _ready() -> void:
	world = find_parent("World")
	health = enemy.health
	damage = enemy.damage
	sprite = $Sprite
	hitbox = $Hitbox
	connect("area_entered", take_damage)
	sprite.texture = enemy.texture
	hitbox.shape.radius = (sprite.texture.get_size().x / 2.0) * sprite.scale[0]
	
func take_damage(area):
	if area is Orbitable:
		health -= area.item.data.damage
		flash_damage()
		if health <= 0:
			var particle = vanish_particle_scene.instantiate()
			particle.emitting = true
			particle.global_position = global_position
			world.add_child(particle)
			drop_loot()
			queue_free()

func flash_damage():
	# Set to fully red
	sprite.material.set_shader_parameter("damage_flash", 0.7)
	
	# Animate fade back to 0 over 0.3 seconds
	tween.kill()  # Kill any existing tween first
	tween = get_tree().create_tween()
	tween.tween_property(sprite.material, "shader_parameter/damage_flash", 0.0, 0.3)

func drop_loot():
	var spawned_loot = []

	# Determine which items will spawn
	for drop in enemy.drops:
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
