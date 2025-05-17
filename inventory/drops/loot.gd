extends Node2D

var rarity_map = {
	"common": load("res://inventory/drops/loot_common.tres"),
	"uncommon": load("res://inventory/drops/loot_uncommon.tres"),
	"rare": load("res://inventory/drops/loot_rare.tres"),
	"epic": load("res://inventory/drops/loot_epic.tres"),
	"mythic": load("res://inventory/drops/loot_mythic.tres"),
	"legendary": load("res://inventory/drops/loot_legendary.tres")
}
var texture_node: Node
var panel: Node

@export var item_data: ItemData

func _ready() -> void:
	panel = find_child("PanelContainer")
	texture_node = find_child("Texture")
	panel.add_theme_stylebox_override("panel", rarity_map[item_data.rarity.to_lower()])
	texture_node.texture = item_data.texture
	connect("body_entered", pickup)
	
	
func pickup(body):
	if body.name == "Player":
		body.add_item(item_data)
		queue_free()
