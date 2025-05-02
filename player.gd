extends CharacterBody2D

const SPEED = 300
const JUMP_VELOCITY = 400
const ACCELERATION = 2000
const FRICTION = 300

@export var inv: Inv
@export var hotbar: Hotbar
@onready var planet_sprite = get_node("Sprite")
@onready var orbitable_scene = preload("res://orbitable.tscn")
@onready var amount = hotbar.items.size()
 
func _ready():
	for i in hotbar.items.size():
		var item = hotbar.items[i]
		var orbitable = orbitable_scene.instantiate()
		orbitable.get_node("Sprite").texture = item.texture
		orbitable.index = i
		add_child(orbitable)

func player_movement(input, delta):

	if input: velocity = velocity.move_toward(input * SPEED , delta * ACCELERATION)

	else: velocity = velocity.move_toward(Vector2(0,0), delta * FRICTION)


func _physics_process(delta):
	var input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")

	player_movement(input, delta)
	planet_sprite.rotation += delta * 0.5
	move_and_slide()
