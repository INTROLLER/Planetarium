extends RigidBody2D

var d = 0
const SPEED = 3          # angular speed (rad/s)
const LERP_SPEED = 15.0   # controls how smoothly it follows
var max_amount = 0
var start_angle = 0
var orbit_center := Vector2.ZERO
var current_radius : float

@export var index: int

@onready var parent = get_parent()
@onready var parent_col_shape = parent.get_node("Hitbox")
@onready var RADIUS = parent_col_shape.shape.radius * parent_col_shape.scale[0] + $Hitbox.shape.radius * $Hitbox.scale[0] * 3

func _ready() -> void:
	current_radius = RADIUS
	orbit_center = parent.global_position
	upd()

func upd():
	for i in parent.loadout.items.size():
		var item = parent.loadout.items[i]
		if item == null:
			continue
		max_amount += 1
		
	start_angle = ((2 * PI) / max_amount) * index
	max_amount = 0

func _physics_process(delta):
	var input = Input.is_physical_key_pressed(KEY_SPACE)
	var target_radius = RADIUS * (1.7 if input else 1)
	current_radius = lerp(current_radius, target_radius, LERP_SPEED * delta) # Smoothly interpolate
	d += delta * SPEED
	orbit_center = orbit_center.lerp(parent.global_position, delta * LERP_SPEED / (3.5 if input else 2))
	var offset = Vector2(cos(start_angle + d), sin(start_angle + d)) * current_radius
	var target_position = orbit_center + offset
	global_position = global_position.lerp(target_position, delta * LERP_SPEED)
	angular_velocity = 5
