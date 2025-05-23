class_name Enemy

extends Area2D  # Extend Area2D to use 2D collision detection and signals

# Node and resource references
var sprite: Node                 # Reference to the Sprite node for visual representation
var hitbox: Node                 # Reference to the CollisionShape2D (Hitbox) for detecting overlaps
var world: World                 # Reference to the parent World node for global game state
var tween: Tween                 # Tween used for smooth property animations (e.g., scaling, color)
var player: Player               # Reference to the Player node for AI targeting and interactions
var inventory: Node              # Reference to the player's inventory UI (InvUi)
var hotbar: Node                 # Reference to the player's hotbar UI (HotbarUi)
var player_stats_ui: Node        # Reference to the player's stats UI (PlayerStatsUi)

# Exported data defining this enemy’s configuration
@export var data: EnemyData      # EnemyData resource containing texture, drops, base stats
@export var health: float        # Current health of this enemy
@export var damage: float        # Damage this enemy deals to the player

# Preload scenes for loot drop and vanish particle effect
var loot_scene = load("res://inventory/loot/loot.tscn")
var vanish_particle_scene = load("res://vanish_particle.tscn")

# Movement and physics variables
var velocity := Vector2.ZERO     # Current velocity (used for knockback interpolation)
var friction := 1000.0           # Rate at which knockback decays per second
var knockback_force := 300.0     # Strength of knockback applied when hit
var knockback_threshold := 5.0   # Minimum velocity threshold to continue knockback movement
var move_speed := 80.0           # Base movement speed when chasing the player

func _ready() -> void:
    # Called when this Enemy node enters the scene tree

    world = find_parent("World")
    # Cache the World node (assumed to be an ancestor) for accessing global state/signals

    player = world.get_node("Player")
    # Cache the Player node (child of World) for target tracking

    inventory = player.find_child("InvUi")
    hotbar = player.find_child("HotbarUi")
    player_stats_ui = player.find_child("PlayerStatsUi")
    # Cache references to UI elements on the Player in case they need toggling on game over

    health = data.health
    damage = data.damage
    # Initialize health and damage from the exported EnemyData

    sprite = $Sprite
    hitbox = $Hitbox
    # Cache child nodes: the Sprite for visuals, and the Hitbox (CollisionShape2D) for detecting hits

    # Connect signals for collision detection
    area_entered.connect(get_hit)
    # When an Area2D (e.g., a projectile or orbitable item) enters this enemy’s area, call get_hit()

    body_entered.connect(hit)
    # When a PhysicsBody2D (e.g., the Player) enters this enemy’s area, call hit()

    # Configure the sprite’s texture and scale to a consistent size (50x50)
    sprite.texture = data.texture
    sprite.scale.x = 50 / sprite.texture.get_size().x
    sprite.scale.y = 50 / sprite.texture.get_size().y

    # Set the hitbox radius based on the scaled sprite size
    hitbox.shape.radius = (sprite.texture.get_size().x / 2.0) * sprite.scale[0]

    add_to_group("enemies")
    # Add this node to the “enemies” group so other enemies can detect and separate from it


func _physics_process(delta: float) -> void:
    # Called each physics frame to update movement and separation behavior

    separate_from_enemies()
    # Apply separation force so enemies don’t overlap each other

    if velocity.length() > knockback_threshold:
        # If current velocity (knockback) is above the threshold, apply knockback
        global_position += velocity * delta
        # Move the enemy by the knockback velocity

        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
        # Reduce velocity toward zero using friction
    else:
        # Once knockback has decayed below threshold, clear velocity and resume chasing
        velocity = Vector2.ZERO

        if player:
            var direction = (player.global_position - global_position).normalized()
            # Compute normalized direction vector toward the player

            global_position += direction * move_speed * delta
            # Move the enemy toward the player at move_speed


func get_hit(area):
    # Called when another Area2D (e.g., an Orbitable projectile) enters this enemy's area
    if area is Orbitable:
        # Only process hits from projectiles or other orbitable attacks
        health -= area.item.data.damage
        # Subtract damage based on the projectile’s item data
        flash_damage()
        # Show a brief red flash to indicate damage taken
        check_death()
        # Check if health has dropped to zero or below after taking damage


func hit(body):
    # Called when a PhysicsBody2D (e.g., the Player) collides with this enemy
    if body is Player:
        # Deal damage to the player
        body.health -= damage
        # Also take damage from the player’s “body_damage” field (e.g., melee counterattack)
        health -= body.body_damage

        # Apply knockback to this enemy away from the player
        var direction = (global_position - body.global_position).normalized()
        velocity += direction * knockback_force
        flash_damage()
        body.flash_damage()
        # Flash both this enemy and the player to indicate simultaneous damage

        check_death()
        # Check if the enemy died from the player's counter-damage

        if body.health <= 0:
            # If the player died as a result of this collision, end the game
            world.stop_game(player.death_screen)

            if inventory.visible:
                # If the inventory UI was open when the player died, close it and show other UI
                hotbar.visible = true
                player_stats_ui.visible = true

                var tween2 = inventory.get_tree().create_tween()
                tween2.tween_property(inventory, "scale", Vector2(0, 0), 0.1)
                # Scale down inventory over 0.1 seconds

                var tween3 = hotbar.get_tree().create_tween()
                tween3.tween_property(hotbar, "position", Vector2(200.0, 197.0), 0.1)
                # Animate hotbar back to its default position

                var tween4 = player_stats_ui.get_tree().create_tween()
                tween4.tween_property(player_stats_ui, "position", Vector2(0, 0), 0.1)
                # Animate player stats UI back to default position

                await tween2.finished
                inventory.visible = false
                # Finally, hide the inventory once its scale animation completes


func check_death():
    # Evaluates whether this enemy’s health has reached zero and handles death logic
    if health <= 0:
        # Spawn a vanish particle effect at the enemy’s position
        var particle = vanish_particle_scene.instantiate()
        particle.emitting = true
        particle.global_position = global_position
        world.add_child(particle)

        drop_loot()
        # Attempt to drop loot based on the EnemyData’s drop table

        if tween:
            tween.kill()
            # If a tween is already running (e.g., flash or previous animation), kill it

        tween = get_tree().create_tween()
        tween.tween_property(sprite, "scale", Vector2(0.0, 0.0), 0.1)
        # Animate the sprite scaling down to zero over 0.1 seconds

        await tween.finished
        queue_free()
        # Remove (free) this enemy node from the scene

        world.killed_enemies += 1
        world.enemy_killed.emit()
        # Increment the global kill count and emit a signal for UI updates


func flash_damage():
    # Briefly flash the enemy’s color to indicate taking damage
    modulate = Color(3.314, 1.0, 1.0)
    # Set a reddish tint (values >1.0 amplify red channel)

    if tween:
        tween.kill()
        # Stop any ongoing tween before starting a new one

    tween = get_tree().create_tween()
    tween.tween_property(self, "modulate", Color(1.4, 1.4, 1.4), 0.3)
    # Animate the modulate back toward neutral (light gray), over 0.3 seconds


func drop_loot():
    # Spawns loot items around the enemy’s position when it dies
    var spawned_loot = []

    # Determine which items from the drop table should actually spawn
    for drop in data.drops:
        if randf() < drop.probability:
            spawned_loot.append(drop)

    if spawned_loot.is_empty():
        return
        # If no items passed the probability check, do nothing

    # Compute a grid layout for the spawned loot based on how many items there are
    var total = spawned_loot.size()
    var cols = int(ceil(sqrt(total)))
    var spacing = 27
    var rows = int(ceil(float(total) / cols))

    for i in range(total):
        var row = i / float(cols)
        var col = i % cols

        # Determine how many items are in this particular row (handles uneven last row)
        var items_in_row = cols
        if row == rows - 1 and total % cols != 0:
            items_in_row = total % cols

        # Calculate the horizontal start offset so items in the row are centered
        var row_width = (items_in_row - 1) * spacing
        var start_x = -row_width / 2.0
        var start_y = -((rows - 1) * spacing) / 2.0

        # Prevent index overflow for the last row if it’s not completely filled
        if row == rows - 1 and col >= items_in_row:
            continue

        # Compute the position offset for this loot instance in the grid
        var offset = Vector2(start_x + col * spacing, start_y + row * spacing)

        # Instantiate a Loot node and set its item_data, position it, and add to the world
        var loot = loot_scene.instantiate()
        loot.item_data = spawned_loot[i].data
        loot.global_position = global_position + offset
        find_parent("World").add_child(loot)


func separate_from_enemies():
    # Applies a repulsion force between enemies to prevent them from overlapping
    var enemies = get_tree().get_nodes_in_group("enemies")
    var separation_force = Vector2.ZERO

    for other in enemies:
        if other == self:
            continue  # Skip ourselves

        var distance = global_position.distance_to(other.global_position)
        var min_distance = (hitbox.shape.radius + other.hitbox.shape.radius)
        # Compute the minimum allowed distance between the two circles

        if distance < min_distance and distance > 0:
            # If they are overlapping, compute a push-away direction
            var push_direction = (global_position - other.global_position).normalized()
            var overlap = min_distance - distance

            # Determine a force that is at least a minimum to avoid getting stuck
            var push_strength = max(overlap * 10, 200)
            separation_force += push_direction * push_strength

    velocity += separation_force
    # Add the computed separation force to the current velocity so physics_process will move the enemy away