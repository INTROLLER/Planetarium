extends RigidBody2D

var d = 0
const SPEED = 2 # angular speed (rad/s)

@export var index: int

@onready var parent = get_parent()
@onready var parent_col_shape = parent.get_node("Hitbox")
@onready var RADIUS = parent_col_shape.shape.radius * parent_col_shape.scale[0] + $Hitbox.shape.radius * $Hitbox.scale[0] * 2
@onready var max_amount = parent.hotbar.items.size()
@onready var start_angle = ((2 * PI) / max_amount) * index
@onready var current_radius = RADIUS

func _physics_process(delta):
	var input = Input.is_physical_key_pressed(KEY_SPACE)
	var target_radius = RADIUS * (2 if input else 1)
	current_radius = lerp(current_radius, target_radius, 10 * delta) # Smoothly interpolate

	d += delta * SPEED
	var center = parent.global_position
	var offset = Vector2(cos(start_angle + d), sin(start_angle + d)) * current_radius
	var target_position = center + offset
	var distance = target_position - global_position

	linear_velocity = distance * SPEED * current_radius * 0.4
	angular_velocity = 5
