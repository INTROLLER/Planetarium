extends RigidBody2D

var d = 0
const SPEED = 2 # angular speed (rad/s)

@export var index: int

@onready var parent = get_parent()
@onready var parent_col_shape = parent.get_node("CollisionShape2D")
@onready var RADIUS = parent_col_shape.shape.radius * parent_col_shape.scale[0] + get_node("CollisionShape2D").shape.radius * 2
@onready var max_amount = parent.hotbar.items.size()
@onready var start_angle = ((2 * PI) / max_amount) * index

func _physics_process(delta):
	d += delta
	position = Vector2(cos(start_angle + d), sin(start_angle + d)) * RADIUS
	angular_velocity = 0
