class_name Player
extends CharacterBody2D

# Custom signals
signal health_changed(health)       # Emitted when player's health changes
signal loot_collected(item_data)    # Emitted when player collects loot

# Movement constants
const SPEED = 130
const JUMP_VELOCITY = 400
const ACCELERATION = 2000
const FRICTION = 300

# References to scene nodes
var inv_container: Node
var hitbox: Node
var sprite: Node
var tween: Tween
var world: World

# Exported variables for the inspector
@export var health: float
@export var max_health: float
@export var body_damage: float
@export var main_menu: Node
@export var death_screen: Node
@export var inv: Inv                   # Player's inventory
@export var loadout: Loadout          # Currently equipped items
@export var playing: bool             # Whether the game is in play mode

# Orbitable system (rotating items around player)
var orbitable_scene = load("res://orbitable.tscn")
var next_id = 1
var orbitables := []
var health_stat := 100.0              # Base health stat (for reset)

func _ready():
    # Initialize references
    world = find_parent("World")
    sprite = $Sprite
    hitbox = $Hitbox

    # Scale the sprite to 50px size
    sprite.scale.x = 50 / sprite.texture.get_size().x
    sprite.scale.y = 50 / sprite.texture.get_size().y

    # Setup hitbox radius
    hitbox.shape.radius = (sprite.texture.get_size().x / 2.0) * sprite.scale[0]

    # Connect world signal to setup game start
    world.game_started.connect(setup)

    # Reference to inventory UI container
    inv_container = get_node("CanvasLayer/InvUi").find_child("InvContainer")

    # Load previously equipped items into orbit
    upd_loadout()

    # Initialize inventory items
    for i in inv.items.size():
        var item = inv.items[i]
        item.id = next_id
        inv_container.add(item)
        next_id += 1

func _physics_process(delta):
    # Skip physics if not in playing state
    if not playing:
        return

    # Get directional input from player
    var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    # Apply movement logic
    player_movement(input, delta)

    # Slow rotation animation for sprite
    sprite.rotation += delta * 0.5

    # Move using Godot's physics engine
    move_and_slide()

func upd_loadout():
    # Remove old orbitables
    for o in orbitables:
        remove_child(o)
    orbitables.clear()

    # Add new orbitables from loadout
    for i in loadout.items.size():
        var item = loadout.items[i]
        if item == null:
            continue

        var orbitable = orbitable_scene.instantiate()
        orbitable.index = i
        orbitable.item = item
        add_child(orbitable)
        orbitables.append(orbitable)

    # Update each orbitable with its position
    for o in orbitables:
        o.upd()

func add_item(item_data: ItemData):
    # Add a new item to the inventory
    var item = Item.new()
    item.data = item_data
    item.id = next_id
    inv.items.append(item)
    inv_container.add(item)
    next_id += 1

func flash_damage():
    # Emit health update signal
    health_changed.emit(health)

    # Flash red on damage
    modulate = Color(3.314, 1.0, 1.0)  # Light red

    # Animate fade back to normal color
    if tween:
        tween.kill()
    tween = get_tree().create_tween()
    tween.tween_property(self, "modulate", Color(1.4, 1.4, 1.4), 0.3)

func player_movement(input, delta):
    # Accelerate toward direction or decelerate to stop
    if input:
        velocity = velocity.move_toward(input * SPEED , delta * ACCELERATION)
    else:
        velocity = velocity.move_toward(Vector2(0, 0), delta * FRICTION)

func setup():
    # Reset health on game start
    health = health_stat
    max_health = health

    # Notify UI about initial health
    health_changed.emit(health)
