extends Area2D

class_name Orbitable

const SPEED = 3          # angular speed (rad/s)
const LERP_SPEED = 15.0   # controls how smoothly it follows

var d = 0
var max_amount = 0
var start_angle = 0
var orbit_center := Vector2.ZERO
var base_radius: float
var current_radius: float

var player: Node
var player_hitbox: Node
var hitbox: Node
var sprite: Node

@export var index: int
@export var item: Item

func _ready() -> void:
	player = get_parent()
	player_hitbox = player.get_node("Hitbox")
	hitbox = $Hitbox
	sprite = $Sprite
	hitbox.shape.radius = (sprite.texture.get_size().x / 2.0) * sprite.scale[0]
	base_radius = player_hitbox.shape.radius * player_hitbox.scale[0] + hitbox.shape.radius * hitbox.scale[0] * 3
	current_radius = base_radius
	orbit_center = player.global_position
	sprite.texture = item.data.texture
	upd()

func upd():
	for i in player.loadout.items.size():
		var item = player.loadout.items[i]
		if item == null:
			continue
		max_amount += 1
		
	start_angle = ((2 * PI) / max_amount) * index
	max_amount = 0

func _physics_process(delta):
	var input = Input.is_physical_key_pressed(KEY_SPACE)
	var target_radius = base_radius * (1.7 if input else 1)
	current_radius = lerp(current_radius, target_radius, LERP_SPEED * delta) # Smoothly interpolate
	d += delta * SPEED
	orbit_center = orbit_center.lerp(player.global_position, delta * LERP_SPEED / (3.5 if input else 2))
	var offset = Vector2(cos(start_angle + d), sin(start_angle + d)) * current_radius
	var target_position = orbit_center + offset
	global_position = global_position.lerp(target_position, delta * LERP_SPEED)
