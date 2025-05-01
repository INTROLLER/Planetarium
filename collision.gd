extends RigidBody2D

var rng = RandomNumberGenerator.new()
var d = rng.randf_range(-1, 1)    # random phase offset
const SPEED = 2 # angular speed (rad/s)
const STIFFNESS = 8 # spring constant for radial correction

@onready var parent            = get_parent()
@onready var parent_col_shape = parent.get_node("CollisionShape2D")
@onready var RADIUS = parent_col_shape.shape.radius * parent_col_shape.scale[0] \
					  + get_node("CollisionShape2D").shape.radius * 1.5

func _ready():
	# initial placement on the circle, relative to parent
	var angle = -d * SPEED
	global_position = parent.global_position + Vector2(
		sin(angle) * RADIUS,
		cos(angle) * RADIUS
	)

func _integrate_forces(state):
	# advance our phase (d tracks elapsed physics‐time)
	d += state.step

	# VECTOR FROM CENTER TO US
	var center = parent.global_position
	var r_vec  = global_position - center
	var r = r_vec.length()

	# GUARD AGAINST ZERO
	if r == 1:
		return

	# UNIT RADIAL & TANGENT
	var radial_unit = r_vec / r
	var tangent = Vector2(-radial_unit.y, radial_unit.x)

	# 1) Tangential velocity to orbit at SPEED: |v| = ωR
	var v_tangent = tangent * (SPEED * RADIUS)

	# 2) Radial “spring” velocity correction: v_radial = –k·(r – R)
	var radial_error = r - RADIUS
	var v_radial = -STIFFNESS * radial_error * radial_unit

	# COMBINE AND APPLY
	linear_velocity = v_tangent + v_radial
	angular_velocity = 0
