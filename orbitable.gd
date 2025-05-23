class_name Orbitable

extends Area2D

# Constants for orbit behavior
const SPEED = 3           # Angular speed in radians per second
const LERP_SPEED = 15.0   # How quickly the orbiting object moves toward its target position

# References and state variables
var base_radius: float              # Base orbit radius
var current_radius: float           # Radius that can change smoothly
var player: Player                  # Reference to the player node
var player_hitbox: Node             # Player's hitbox used for calculating base orbit radius
var hitbox: Node                    # Orbitable's hitbox
var sprite: Node                    # Sprite for visual representation

@export var index: int              # The index of this orbitable in the player's loadout
@export var item: Item              # The item this orbitable represents

# Internal timing and position variables
var d = 0                           # Accumulated time used to calculate orbit angle
var max_amount = 0                 # Total number of active orbitables
var start_angle = 0                # Starting angle offset based on index
var orbit_center := Vector2.ZERO   # Center point of orbit (typically player's position)

func _ready() -> void:
    # Initialize references and set up visuals
    player = get_parent()
    player_hitbox = player.get_node("Hitbox")
    hitbox = $Hitbox
    sprite = $Sprite

    # Set the texture and scale for this orbitable
    sprite.texture = item.data.texture
    sprite.scale.x = 25 / sprite.texture.get_size().x
    sprite.scale.y = 25 / sprite.texture.get_size().y

    # Set hitbox radius based on the sprite's visual size
    hitbox.shape.radius = (sprite.texture.get_size().x / 2.0) * sprite.scale[0]

    # Calculate base orbit radius
    base_radius = player_hitbox.shape.radius * player_hitbox.scale[0] + hitbox.shape.radius * hitbox.scale[0] * 3
    current_radius = base_radius

    # Initial orbit center is player's position
    orbit_center = player.global_position

    # Set orbit angle based on index
    upd()

func _physics_process(delta):
    # Adjust orbit radius when holding space key (for extended orbit)
    var input = Input.is_physical_key_pressed(KEY_SPACE)
    var target_radius = base_radius * (1.7 if input else 1)
    current_radius = lerp(current_radius, target_radius, LERP_SPEED * delta)

    # Update angle for rotation
    d += delta * SPEED

    # Smoothly interpolate orbit center toward player's current position
    orbit_center = orbit_center.lerp(player.global_position, delta * LERP_SPEED / (3.5 if input else 2))

    # Calculate new position based on current angle and radius
    var offset = Vector2(cos(start_angle + d), sin(start_angle + d)) * current_radius
    var target_position = orbit_center + offset

    # Smoothly move the orbitable toward its target position
    global_position = global_position.lerp(target_position, delta * LERP_SPEED)

func upd():
    # Recalculate the starting angle based on total active orbitables
    for i in player.loadout.items.size():
        var current_item = player.loadout.items[i]
        if current_item == null:
            continue
        max_amount += 1

    # Angle offset depends on number of orbitables and this orbitable's index
    start_angle = ((2 * PI) / max_amount) * index
    max_amount = 0  # Reset for future updates