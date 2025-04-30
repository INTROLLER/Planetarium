extends RigidBody2D

var d = 0
var SPEED = 2

@onready var parent = get_parent()
@onready var parent_col_shape = parent.get_node("CollisionShape2D")
@onready var RADIUS = parent_col_shape.shape.radius * parent_col_shape.scale[0] + get_node("CollisionShape2D").shape.radius

func _physics_process(delta):
	d += delta
	position = Vector2(sin(-d * SPEED) * RADIUS, cos(-d * SPEED) * RADIUS)
