# In zombie.gd - Enhanced damage system
extends CharacterBody2D
class_name Zombie

@export var zombie_data: ZombieData
@export var armor: Resource = null # ArmorData resource
var is_dead: bool = false
var damage_area: Area2D # Store reference to damage area
var player_in_damage_area: bool = false # Track if player is in damage area

# Debug visualization for zombie sight range
var sight_range_node: Area2D
var debug_sight_enabled: bool = true

func _ready():
    _initialize_zombie_data()
    _setup_collision_layers()
    _setup_zombie_sight_range() # Renamed for clarity
    _setup_damage_area()
    add_to_group("zombies")
    
    # Set zombie type color but let PlayerSight control visibility
    _set_zombie_type_color()
    
    # IMPORTANT: Start invisible - PlayerSight will make visible when appropriate
    visible = false
    modulate = Color.WHITE

# Add this new method to set correct colors
func _set_zombie_type_color():
    var color_rect = $CollisionShape2D/ColorRect
    if not color_rect or not zombie_data:
        return
    
    match zombie_data.zombie_type:
        EntitiesType.ZombieType.WALKER:
            color_rect.color = Color.WEB_GREEN
        EntitiesType.ZombieType.RUNNER:
            color_rect.color = Color.ORANGE
        EntitiesType.ZombieType.BRUTE:
            color_rect.color = Color.DARK_RED
        _:
            color_rect.color = Color.GREEN

func _initialize_zombie_data():
    if not zombie_data:
        zombie_data = ZombieData.new()
        print("Created new ZombieData - Health: ", zombie_data.health, "/", zombie_data.max_health)

func _setup_damage_area():
    damage_area = Area2D.new()
    damage_area.name = "DamageArea"
    add_child(damage_area)
    
    var damage_collision = CollisionShape2D.new()
    var damage_shape = CircleShape2D.new()
    damage_shape.radius = 25
    damage_collision.shape = damage_shape
    damage_area.add_child(damage_collision)
    
    damage_area.collision_mask = PhysicsLayers.PLAYER
    damage_area.collision_layer = 0
    
    _connect_damage_signals()

# FIXED: This is for ZOMBIE AI sight, not player sight
func _setup_zombie_sight_range():
    var sight_range = $SightRange
    if not sight_range:
        # Create zombie's own sight range for AI
        sight_range = Area2D.new()
        sight_range.name = "SightRange"
        add_child(sight_range)
        
        var collision_shape = CollisionShape2D.new()
        var circle_shape = CircleShape2D.new()
        circle_shape.radius = zombie_data.sight_range if zombie_data else 150.0
        collision_shape.shape = circle_shape
        sight_range.add_child(collision_shape)
    
    # Store reference for debug visualization
    sight_range_node = sight_range
    
    # This is for zombie AI to detect player
    sight_range.collision_layer = 0
    sight_range.collision_mask = PhysicsLayers.PLAYER
    
    # Update the CircleShape2D radius to match zombie_data.sight_range
    var collision_shape = sight_range.get_node("CollisionShape2D")
    if collision_shape and collision_shape.shape is CircleShape2D:
        collision_shape.shape.radius = zombie_data.sight_range if zombie_data else 150.0
    
    _connect_sight_signals()

func _setup_collision_layers():
    collision_layer = PhysicsLayers.ENEMIES
    collision_mask = PhysicsLayers.PLAYER | PhysicsLayers.WALLS

func _connect_damage_signals():
    damage_area.body_entered.connect(_on_damage_area_body_entered)
    damage_area.body_exited.connect(_on_damage_area_body_exited)

func _connect_sight_signals():
    var sight_range = get_node_or_null("SightRange")
    if sight_range:
        # Make sure we're not double-connecting
        if not sight_range.body_entered.is_connected(_on_player_entered_zombie_sight):
            sight_range.body_entered.connect(_on_player_entered_zombie_sight)
        if not sight_range.body_exited.is_connected(_on_player_left_zombie_sight):
            sight_range.body_exited.connect(_on_player_left_zombie_sight)
        print("Zombie sight signals connected for ", self.name)
    else:
        print("ERROR: Could not connect sight signals - SightRange not found")

# FIXED: Initial detection triggers immediately, line-of-sight checked continuously
func _on_player_entered_zombie_sight(body):
    print("Player entered zombie sight range: ", self.name)
    if body.is_in_group("player"):
        # Store player reference for continuous line-of-sight checking
        zombie_data.detected_player = body
        print("Zombie ", self.name, " detected player - checking line of sight...")
        
        # Check line of sight immediately
        if _has_line_of_sight_to_player(body):
            zombie_data.state = ZombieData.ZombieState.CHASING
            zombie_data.target_position = body.global_position
            print("Zombie ", self.name, " has line of sight - starting chase!")
        else:
            print("Zombie ", self.name, " player behind wall - waiting for clear sight")

func _on_player_left_zombie_sight(body):
    print("Player left zombie sight range: ", self.name)
    if body.is_in_group("player"):
        zombie_data.detected_player = null
        # Continue to last known position if we were chasing
        if zombie_data.state == ZombieData.ZombieState.CHASING:
            print("Zombie ", self.name, " lost sight - continuing to last known position")

func _physics_process(delta):
    if not zombie_data or is_dead:
        return
    
    # Continuous line-of-sight check for detected player
    if zombie_data.detected_player and is_instance_valid(zombie_data.detected_player):
        var has_los = _has_line_of_sight_to_player(zombie_data.detected_player)
        var is_in_range = _is_player_in_zombie_sight_range(zombie_data.detected_player)
        
        if has_los and is_in_range and zombie_data.state == ZombieData.ZombieState.IDLE:
            # Player came out from behind wall - start chasing
            zombie_data.state = ZombieData.ZombieState.CHASING
            zombie_data.target_position = zombie_data.detected_player.global_position
            print("Zombie ", self.name, " player visible again - starting chase!")
        elif not has_los and zombie_data.state == ZombieData.ZombieState.CHASING:
            # Player went behind wall - keep target position for searching
            print("Zombie ", self.name, " lost line of sight - will search last known position")
        elif not is_in_range:
            # Player left sight range completely
            zombie_data.detected_player = null
            if zombie_data.target_position == Vector2.ZERO:
                zombie_data.state = ZombieData.ZombieState.IDLE
    
    # Execute movement based on state
    match zombie_data.state:
        ZombieData.ZombieState.IDLE:
            velocity = Vector2.ZERO
        ZombieData.ZombieState.CHASING:
            chase_target(delta)
        ZombieData.ZombieState.DEAD:
            velocity = Vector2.ZERO
    
    # Always call move_and_slide() in physics process
    move_and_slide()

func chase_target(delta):
    var player = zombie_data.detected_player
    
    # Direct chase if player is visible and in range
    if player and is_instance_valid(player) and _is_player_in_zombie_sight_range(player) and _has_line_of_sight_to_player(player):
        # Direct chase - player is visible
        var target_direction = (player.global_position - global_position).normalized()
        var movement_direction = _get_avoidance_direction(target_direction)
        velocity = movement_direction * zombie_data.speed
        zombie_data.target_position = player.global_position
        print("Zombie ", self.name, " directly chasing player")
        
    elif zombie_data.target_position != Vector2.ZERO:
        # Move to last known position
        var distance_to_target = global_position.distance_to(zombie_data.target_position)
        
        if distance_to_target > 32.0:
            var target_direction = (zombie_data.target_position - global_position).normalized()
            var movement_direction = _get_avoidance_direction(target_direction)
            velocity = movement_direction * zombie_data.speed * 0.7
            print("Zombie ", self.name, " searching at distance: ", distance_to_target)
        else:
            # Reached target position
            print("Zombie ", self.name, " reached target position")
            zombie_data.target_position = Vector2.ZERO
            # Only go idle if player is not detected or not in range
            if not zombie_data.detected_player or not _is_player_in_zombie_sight_range(zombie_data.detected_player):
                zombie_data.state = ZombieData.ZombieState.IDLE
                velocity = Vector2.ZERO
                print("Zombie ", self.name, " going idle")
    else:
        # No target - go idle
        zombie_data.state = ZombieData.ZombieState.IDLE
        velocity = Vector2.ZERO
        print("Zombie ", self.name, " no target - going idle")

# SIMPLIFIED: Remove move_and_slide() from here - it's in _physics_process now
# func chase_target(delta): # <-- This is now cleaner

func _has_line_of_sight_to_player(player) -> bool:
    if not player or not is_instance_valid(player):
        return false
        
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.create(
        global_position,
        player.global_position
    )
    query.collision_mask = PhysicsLayers.WALLS # Only check for walls
    query.exclude = [self] # Don't hit the zombie itself
    
    var result = space_state.intersect_ray(query)
    return result.is_empty() # True if no walls block the view

func _is_player_in_zombie_sight_range(player) -> bool:
    var sight_range = get_node_or_null("SightRange")
    if not sight_range or not player:
        return false
    return sight_range.overlaps_body(player)

# Debug visualization methods
func toggle_debug_sight():
    debug_sight_enabled = !debug_sight_enabled
    queue_redraw()
    print("Zombie sight debug: ", "ON" if debug_sight_enabled else "OFF")

func _draw():
    # Only draw if debug is enabled, zombie is visible, and we have sight range data
    if debug_sight_enabled and visible and sight_range_node:
        var sight_radius = _get_zombie_sight_radius()
        if sight_radius > 0:
            # Draw filled circle (more transparent - was 0.05, now 0.025)
            draw_circle(Vector2.ZERO, sight_radius, Color(1, 0, 0, 0.025))
            # Draw circle outline (more transparent - was 0.3, now 0.15)
            draw_arc(Vector2.ZERO, sight_radius, 0, TAU, 64, Color(1, 0, 0, 0.15), 1.5)

func _get_zombie_sight_radius() -> float:
    """Get the actual radius from the zombie's SightRange Area2D"""
    if not sight_range_node:
        return 0.0
    
    var collision_shape = sight_range_node.get_node("CollisionShape2D")
    if not collision_shape:
        return 0.0
    
    var shape = collision_shape.shape
    if shape is CircleShape2D:
        return shape.radius
    
    # Fallback to zombie_data
    return zombie_data.sight_range if zombie_data else 150.0


func _get_avoidance_direction(target_direction: Vector2) -> Vector2:
    var space_state = get_world_2d().direct_space_state
    
    # Check if direct path is blocked
    var query = PhysicsRayQueryParameters2D.create(
        global_position,
        global_position + target_direction * 64.0 # Look ahead 64 pixels
    )
    query.collision_mask = PhysicsLayers.WALLS
    query.exclude = [self]
    
    var result = space_state.intersect_ray(query)
    
    if result.is_empty():
        # Direct path is clear
        return target_direction
    
    # Path is blocked, try left and right alternatives
    var left_direction = target_direction.rotated(-PI / 3) # 60 degrees left
    var right_direction = target_direction.rotated(PI / 3) # 60 degrees right
    
    # Test left path
    query.to = global_position + left_direction * 64.0
    var left_result = space_state.intersect_ray(query)
    
    # Test right path  
    query.to = global_position + right_direction * 64.0
    var right_result = space_state.intersect_ray(query)
    
    # Choose the clearest path
    if left_result.is_empty() and right_result.is_empty():
        # Both paths clear, choose randomly to prevent predictable behavior
        return left_direction if randf() > 0.5 else right_direction
    elif left_result.is_empty():
        return left_direction
    elif right_result.is_empty():
        return right_direction
    else:
        # Both blocked, try sharper angles
        return target_direction.rotated(PI / 2) # 90 degree turn

func _process(delta):
    if is_dead:
        return
        
    # Only handle non-physics stuff here
    zombie_data.update_cooldown(delta)
    
    if player_in_damage_area && zombie_data.can_damage():
        var overlapping = damage_area.get_overlapping_bodies()
        for body in overlapping:
            if body is PlayerController:
                DamageInterface.apply_damage(
                    self,
                    body,
                    zombie_data.damage,
                    DamageInterface.DamageType.CONTACT
                )
                zombie_data.apply_damage_cooldown()
                break # Only damage once per cooldown cycle

# Debug method to check zombie state
func debug_zombie_state():
    print("=== Zombie Debug Info ===")
    print("Name: ", self.name)
    print("State: ", ZombieData.ZombieState.find_key(zombie_data.state))
    print("Detected Player: ", zombie_data.detected_player)
    print("Target Position: ", zombie_data.target_position)
    print("Current Position: ", global_position)
    print("Velocity: ", velocity)
    print("Speed: ", zombie_data.speed)
    print("Sight Range: ", zombie_data.sight_range)
    
    # Additional debug info
    if zombie_data.detected_player:
        var distance = global_position.distance_to(zombie_data.detected_player.global_position)
        var in_range = _is_player_in_zombie_sight_range(zombie_data.detected_player)
        var has_los = _has_line_of_sight_to_player(zombie_data.detected_player)
        print("Player Distance: ", "%.1f" % distance)
        print("Player In Range: ", in_range)
        print("Has Line of Sight: ", has_los)
    
    print("========================")

func _on_damage_area_body_entered(body):
    if body is PlayerController:
        player_in_damage_area = true
        if zombie_data.can_damage():
            DamageInterface.apply_damage(
                self,
                body,
                zombie_data.damage,
                DamageInterface.DamageType.CONTACT
            )
            zombie_data.apply_damage_cooldown()

func _on_damage_area_body_exited(body):
    if body is PlayerController:
        player_in_damage_area = false

func get_resistances() -> Dictionary:
    return zombie_data.get_resistances() if zombie_data else {}

# it is just impossible to outsource this method
func take_damage(amount: int, damage_type: DamageInterface.DamageType):
    if is_dead or not zombie_data.is_alive():
        return

    var resistances = get_resistances()
    var resistance = resistances.get(damage_type, 0.0)
    var final_damage = int(amount * (1.0 - resistance))
    zombie_data.take_damage(final_damage)

    show_damage_flash()

    if zombie_data.health <= 0 and not is_dead:
        die()

func die():
    """Handle zombie death"""
    if is_dead:
        return
    
    is_dead = true
    zombie_data.state = ZombieData.ZombieState.DEAD # Set state first
    
    # Register death with debug manager
    DebugManager.register_zombie_death()
    
    # Disable collision
    set_collision_layer_value(2, false)
    set_collision_mask_value(1, false)
    
    # call loot drop
    var loot_drops = zombie_data.get_loot_drops()
    for drop in loot_drops:
        print("Dropped ", drop["amount"], " of ", drop["item_id"])

    # drop an item pickup at zombie's death position - DEFER THIS
    call_deferred("_create_pickups")
    
    # Remove after brief delay
    await get_tree().create_timer(0.5).timeout
    queue_free()

func _create_pickups():
    # Update ZombieData with current world position before creating pickups
    zombie_data.position = global_position
    """Create pickup items - called deferred to avoid physics state conflicts"""
    var pickup_items = zombie_data.create_pickup_items()
    
    for pickup_item in pickup_items:
        # Load the scene and instantiate it
        var pickup_scene = preload("res://scenes/gameplay/items/item_pickup.tscn")
        var pickup_instance = pickup_scene.instantiate()
        
        # Setup the pickup with data
        pickup_instance.setup(
            pickup_item["item_id"],
            pickup_item["amount"],
            pickup_item["position"]
        )
        
        # Add to scene
        get_tree().current_scene.add_child(pickup_instance)

# Future expansion methods (ready for Day 5 AI)
func get_health_percentage() -> float:
    """Get health as percentage for UI/AI decisions"""
    return zombie_data.health / float(zombie_data.max_health)

func get_direction_to_player() -> Vector2:
    # Get the player node from the scene
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        print("Warning: No player found in scene")
        return Vector2.ZERO
    
    # Calculate direction vector from zombie to player
    var direction = (player.global_position - global_position).normalized()
    return direction

func show_damage_flash():
    # Only affect ColorRect, not zombie modulate
    var color_rect = $CollisionShape2D/ColorRect
    if color_rect:
        var original_color = color_rect.color
        color_rect.color = Color.WHITE
        await get_tree().create_timer(0.1).timeout
        color_rect.color = original_color
    # Don't touch self.modulate - PlayerSight controls that

func set_debug_sight(enabled: bool):
    debug_sight_enabled = enabled
    queue_redraw() # Only redraw when debug state actually changes
