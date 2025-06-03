# Declare the class name so it can be used as a resource type elsewhere
class_name Loot

# This node extends Area2D, allowing for 2D collision detection and overlap signals
extends Area2D

# Node references to be assigned at runtime in _ready()
var texture_node: Node         # The Texture node that displays the item's sprite
var texture_container: Node    # A container (Panel) around the texture for styling and sizing
var hitbox: Node               # The Area2D's collision shape for pickup detection
var particles: Node            # Particle2D node for shine effects
var following_player: Player   # Reference to the player when the loot is being picked up

# Exported ItemData resource that defines what this loot represents
@export var item_data: ItemData

# Multiplier to enlarge the hitbox relative to the item's texture size
var hitbox_multi = 1.5

# Flag for whether the loot is currently in the process of fading toward the player
var fading_out := false

# Mapping from rarity strings to styleboxes and particle colors
var rarity_map = {
	"common": {
		"stylebox": load("res://inventory/loot/loot_common.tres"),
		"particle_color": "#ffffff"
	},
	"uncommon": {
		"stylebox": load("res://inventory/loot/loot_uncommon.tres"),
		"particle_color": "#74ff00"
	},
	"rare": {
		"stylebox": load("res://inventory/loot/loot_rare.tres"),
		"particle_color": "#1db2ff"
	},
	"epic": {
		"stylebox": load("res://inventory/loot/loot_epic.tres"),
		"particle_color": "#a792ff"
	},
	"mythic": {
		"stylebox": load("res://inventory/loot/loot_mythic.tres"),
		"particle_color": "#ff604f"
	},
	"legendary": {
		"stylebox": load("res://inventory/loot/loot_legendary.tres"),
		"particle_color": "#fefe00"
	}
}

func _ready() -> void:
	# Called when this Loot node enters the scene tree

	# Cache references to sub-nodes for quick access
	hitbox = $Hitbox
	texture_container = $TextureContainer
	particles = $ShineParticles
	texture_node = $TextureContainer/MarginContainer/Texture

	# Apply the correct stylebox to the texture_container based on item rarity
	# Convert the rarity string to lowercase and look up in the rarity_map
	texture_container.add_theme_stylebox_override("panel",
		rarity_map[item_data.rarity.to_lower()]["stylebox"]
	)

	# Set the texture node to display the item's icon or sprite
	texture_node.texture = item_data.texture

	# Calculate and set the hitbox radius based on the container's size and scale
	hitbox.shape.radius = (texture_container.size.x / 2.0) * texture_container.scale[0] * hitbox_multi

	# Set the particle emission bounds to match half of the texture_container size
	particles.emission_rect_extents = (texture_container.size / 2.0) * texture_container.scale[0]

	# Customize the particle color according to rarity
	particles.color = rarity_map[item_data.rarity.to_lower()]["particle_color"]

	# Connect the Area2D "body_entered" signal to the pickup() function
	connect("body_entered", pickup)

	# Initially make the loot invisible and scaled down for the "pop-in" effect
	scale = Vector2(0.0, 0.0)
	modulate.a = 0.0

	# Create a Tween to animate the loot appearing smoothly
	var appear_tween = create_tween()
	appear_tween.set_parallel(true)

	# Animate scaling from zero to full size over 0.3 seconds, with a back-ease for a bounce effect
	appear_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Animate fading in the alpha to fully opaque over the same 0.3 seconds
	appear_tween.tween_property(self, "modulate:a", 1.0, 0.3)


func _physics_process(delta: float) -> void:
	# Runs every physics frame; used to move the loot toward the player when collecting
	if fading_out and following_player:
		# Smoothly lerp the global position toward the player's position (exponential ease)
		global_position = global_position.lerp(
			following_player.global_position,
			1.0 - pow(0.001, delta)
		)

		# Rotate the loot smoothly while it's moving toward the player
		rotation = lerp_angle(
			rotation,
			rotation + PI / 2,
			1.0 - pow(0.001, delta)
		)

		# Gradually fade out the loot’s alpha as it approaches the player
		modulate.a = lerp(modulate.a, 0.0, 1.0 - pow(0.01, delta))

		# Once close enough to the player, add the item and free this node
		if global_position.distance_to(following_player.global_position) < 10:
			following_player.add_item(item_data)
			queue_free()


func pickup(body):
	# Called when another PhysicsBody2D enters the Area2D
	if body is Player:
		# Disable the hitbox so we don't trigger multiple times
		hitbox.disabled = true

		# Enable processing so _physics_process runs (needed for fade-out movement)
		set_process(true)

		# Store reference to the player who picked up this loot
		following_player = body

		# Begin the fade-out sequence
		fading_out = true

		# Emit a custom signal on the player to notify that this loot was collected
		body.loot_collected.emit(item_data)
		find_parent("World").find_child("LootPickup").play()
