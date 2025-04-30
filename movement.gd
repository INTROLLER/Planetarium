extends CharacterBody2D

const SPEED = 300
const JUMP_VELOCITY = 400
const ACCELERATION = 2000
const FRICTION = 300

@onready var planet_sprite = get_node("Planet")

func player_movement(input, delta):

	if input: velocity = velocity.move_toward(input * SPEED , delta * ACCELERATION)

	else: velocity = velocity.move_toward(Vector2(0,0), delta * FRICTION)


func _physics_process(delta):
	var input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")

	player_movement(input, delta)
	planet_sprite.rotation += delta * 0.5
	move_and_slide()
