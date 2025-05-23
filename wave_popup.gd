extends PanelContainer

# References to other nodes and scene objects
var world: World
var tween: Tween
var confetti: Node

# Final position where the panel rests when released
var released_pos: Vector2 = Vector2(141.0, 7.0)

func _ready() -> void:
	# Get reference to the World node
	world = find_parent("World")
	
	# Reference to the confetti particle system
	confetti = get_node("Confetti")
	
	# Connect the wave notification signal
	world.new_wave.connect(appear)

	# Set pivot to the center of the panel (for scaling animations)
	pivot_offset = size / 2.0

func appear(notify):
	# Only continue if we are told to notify visually
	if not notify:
		return

	# Stop any existing animation
	if tween:
		tween.kill()

	# Animate scale to full size (show panel)
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	# Wait for scaling in animation to complete
	await tween.finished

	# Trigger confetti particles
	confetti.emitting = true

	# Wait for a brief display period
	await get_tree().create_timer(2.0).timeout

	# Animate scaling back to 0 (hide panel)
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.1)