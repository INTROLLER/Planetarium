extends Node2D

class_name Loot

var rarity_map = {
	"common": {
		"stylebox": load("res://inventory/drops/loot_common.tres"),
		"particle_color": "#ffffff"
	},
	"uncommon": {
		"stylebox": load("res://inventory/drops/loot_uncommon.tres"),
		"particle_color": "#74ff00"
	},
	"rare": {
		"stylebox": load("res://inventory/drops/loot_rare.tres"),
		"particle_color": "#1db2ff"
	},
	"epic": {
		"stylebox": load("res://inventory/drops/loot_epic.tres"),
		"particle_color": "#a792ff"
	},
	"mythic": {
		"stylebox": load("res://inventory/drops/loot_mythic.tres"),
		"particle_color": "#ff604f"
	},
	"legendary": {
		"stylebox": load("res://inventory/drops/loot_legendary.tres"),
		"particle_color": "#fefe00"
	}
}

var hitbox_multi = 1.5

var texture_node: Node
var texture_container: Node
var hitbox: Node
var particles: Node

var following_player: Player
var fading_out := false

@export var item_data: ItemData

func _ready() -> void:
	hitbox = $Hitbox
	texture_container = $TextureContainer
	particles = $ShineParticles
	texture_node = $TextureContainer/MarginContainer/Texture
	texture_container.add_theme_stylebox_override("panel", rarity_map[item_data.rarity.to_lower()]["stylebox"])
	texture_node.texture = item_data.texture
	hitbox.shape.radius = (texture_container.size.x / 2.0) * texture_container.scale[0] * hitbox_multi
	particles.emission_rect_extents = (texture_container.size / 2.0) * texture_container.scale[0]
	particles.color = rarity_map[item_data.rarity.to_lower()]["particle_color"]
	connect("body_entered", pickup)
	
	# Start invisible and scaled down
	scale = Vector2(0.0, 0.0)
	modulate.a = 0.0

	# Smooth appear animation
	var appear_tween = create_tween()
	appear_tween.set_parallel(true)

	# Scale up
	appear_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Fade in
	appear_tween.tween_property(self, "modulate:a", 1.0, 0.3)

	connect("body_entered", pickup)
	
	
func pickup(body):
	if body is Player:
		hitbox.disabled = true
		set_process(true)
		following_player = body
		fading_out = true


func _physics_process(delta: float) -> void:
	if fading_out and following_player:
		# Smooth exponential movement
		global_position = global_position.lerp(following_player.global_position, 1.0 - pow(0.001, delta))

		# Smooth rotation
		rotation = lerp_angle(rotation, rotation + PI / 2, 1.0 - pow(0.001, delta))

		# Smooth fade
		modulate.a = lerp(modulate.a, 0.0, 1.0 - pow(0.01, delta))

		# Close enough to collect
		if global_position.distance_to(following_player.global_position) < 10:
			following_player.add_item(item_data)
			queue_free()
