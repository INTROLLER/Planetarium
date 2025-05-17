extends CharacterBody2D

const SPEED = 130
const JUMP_VELOCITY = 400
const ACCELERATION = 2000
const FRICTION = 300

var next_id = 1
var orbitables := []

var inv_container: Node

@export var health: float
@export var experience: float
@export var inv: Inv
@export var loadout: Loadout

@onready var planet_sprite = get_node("Sprite")
@onready var orbitable_scene = preload("res://orbitable.tscn")
 
func _ready():
	inv_container = get_node("CanvasLayer/InvUi").find_child("InvContainer")
	upd_loadout()
	for i in inv.items.size():
		var item = inv.items[i]
		item.id = next_id
		inv_container.add(item)
		next_id += 1
		
func upd_loadout():
	for o in orbitables:
		remove_child(o)
	orbitables.clear()
	for i in loadout.items.size():
		var item = loadout.items[i]
		if item == null:
			continue
		var orbitable = orbitable_scene.instantiate()
		orbitable.index = i
		orbitable.item = item
		add_child(orbitable)
		orbitables.append(orbitable)
	for o in orbitables:
		o.upd()

func add_item(item_data: ItemData):
	var item = Item.new()
	item.data = item_data
	item.id = next_id
	inv.items.append(item)
	inv_container.add(item)
	next_id += 1

func player_movement(input, delta):
	if input:
		velocity = velocity.move_toward(input * SPEED , delta * ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2(0,0), delta * FRICTION)


func _physics_process(delta):
	var input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")

	player_movement(input, delta)
	planet_sprite.rotation += delta * 0.5
	move_and_slide()
