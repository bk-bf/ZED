# In zombie.gd - Enhanced with A* pathfinding integration
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

# Enhanced position tracking for accurate "last seen" positions
var last_seen_player_position: Vector2 = Vector2.ZERO
var player_exit_position: Vector2 = Vector2.ZERO
var is_tracking_player: bool = false

# Debouncing state change to prevent rapid state changes
var last_state_change_time: float = 0.0
var min_state_change_interval: float = 0.1 # 100ms minimum

# A* Pathfinding integration
var pathfinding_manager: PathfindingManager
var current_path: PackedVector2Array = PackedVector2Array()
var path_index: int = 0
var path_recalc_timer: float = 0.0
var path_recalc_interval: float = 0.5 # Recalculate path every 500ms
var use_pathfinding: bool = false # Toggle between A* and simple movement
var last_pathfinding_target: Vector2 = Vector2.ZERO

func _ready():
    _initialize_zombie_data()
    _setup_collision_layers()
    _setup_zombie_sight_range()
    _setup_damage_area()
    add_to_group("zombies")
    
    DebugManager.register_zombie_spawned()
    _set_zombie_type_color()
    
    visible = false
    modulate = Color.WHITE
    
    _initialize_pathfinding()
    _verify_physics_setup()

func _initialize_pathfinding():
    """Get reference to pathfinding manager"""
    pathfinding_manager = get_tree().get_first_node_in_group("pathfinding")
    if pathfinding_manager:
        use_pathfinding = true
    else:
        print("WARNING: No PathfindingManager found for zombie: ", self.name, " - using simple movement")
        use_pathfinding = false

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

func _setup_zombie_sight_range():
    var sight_range = $SightRange
    if not sight_range:
        sight_range = Area2D.new()
        sight_range.name = "SightRange"
        add_child(sight_range)
        
        var collision_shape = CollisionShape2D.new()
        var circle_shape = CircleShape2D.new()
        circle_shape.radius = zombie_data.sight_range if zombie_data else 150.0
        collision_shape.shape = circle_shape
        sight_range.add_child(collision_shape)
    
    sight_range_node = sight_range
    sight_range.collision_layer = 0
    sight_range.collision_mask = PhysicsLayers.PLAYER
    
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
        if not sight_range.body_entered.is_connected(_on_player_entered_zombie_sight):
            sight_range.body_entered.connect(_on_player_entered_zombie_sight)
        if not sight_range.body_exited.is_connected(_on_player_left_zombie_sight):
            sight_range.body_exited.connect(_on_player_left_zombie_sight)

func toggle_debug_sight():
    debug_sight_enabled = !debug_sight_enabled
    queue_redraw()
    print("Zombie sight debug: ", "ON" if debug_sight_enabled else "OFF")

func _draw():
    if debug_sight_enabled and visible and sight_range_node:
        var sight_radius = _get_zombie_sight_radius()
        if sight_radius > 0:
            # Draw sight range circle
            draw_circle(Vector2.ZERO, sight_radius, Color(1, 0, 0, 0.025))
            draw_arc(Vector2.ZERO, sight_radius, 0, TAU, 64, Color(1, 0, 0, 0.15), 1.5)
        
        # Draw A* path if using pathfinding
        if use_pathfinding and current_path.size() > 0:
            _draw_pathfinding_debug()

func _draw_pathfinding_debug():
    """Draw A* path for debugging"""
    if current_path.size() < 2:
        return
    
    # Convert world positions to local coordinates
    var local_path: PackedVector2Array = PackedVector2Array()
    for point in current_path:
        local_path.append(to_local(point))
    
    # Draw path lines
    for i in range(local_path.size() - 1):
        draw_line(local_path[i], local_path[i + 1], Color.CYAN, 2.0)
    
    # Draw waypoints
    for i in range(local_path.size()):
        var color = Color.YELLOW if i == path_index else Color.CYAN
        draw_circle(local_path[i], 4.0, color)
    
    # Draw current target waypoint larger
    if path_index < local_path.size():
        draw_circle(local_path[path_index], 6.0, Color.RED)

func _get_exit_position_at_boundary(player_pos: Vector2, zombie_pos: Vector2, sight_radius: float) -> Vector2:
    """Calculate precise position where player crossed the sight range boundary"""
    var direction = (player_pos - zombie_pos).normalized()
    return zombie_pos + (direction * sight_radius)

func _follow_astar_path(delta: float, has_los: bool, is_in_range: bool, player: Node2D):
    """Follow the A* calculated path"""
    if path_index >= current_path.size():
        current_path.clear()
        velocity = Vector2.ZERO
        return
    
    var target_waypoint = current_path[path_index]
    var distance_to_waypoint = global_position.distance_to(target_waypoint)
    
    # Check if we should switch to direct pursuit (only if we have a visible player)
    if player and has_los and is_in_range and distance_to_waypoint > 100.0:
        # Player is visible and close - switch to direct chase
        var direction = (player.global_position - global_position).normalized()
        velocity = direction * zombie_data.speed
        
        # Update target position for next path calculation
        if zombie_data.target_position.distance_to(player.global_position) > 32.0:
            zombie_data.target_position = player.global_position
        return
    
    # Follow A* path to waypoint
    if distance_to_waypoint < 20.0:
        # Reached waypoint - advance to next
        path_index += 1
        if path_index >= current_path.size():
            current_path.clear()
            velocity = Vector2.ZERO
        return
    
    # Move toward current waypoint
    var direction = (target_waypoint - global_position).normalized()
    velocity = direction * zombie_data.speed

func _on_player_left_zombie_sight(body):
    if body.is_in_group("player") and zombie_data.detected_player == body:
        # Calculate precise exit position at sight range boundary
        var new_exit_position = _get_exit_position_at_boundary(
            last_seen_player_position,
            global_position,
            zombie_data.sight_range
        )
        
        # Only update if this is a genuinely new position
        if player_exit_position.distance_to(new_exit_position) > 32.0:
            player_exit_position = new_exit_position
            zombie_data.target_position = player_exit_position
            
            # Clear current path so it recalculates to new exit position
            current_path.clear()
            path_recalc_timer = path_recalc_interval
        
        is_tracking_player = false

func _use_simple_movement(target_pos: Vector2, has_los: bool, is_in_range: bool, player: Node2D):
    """Fallback to simple movement when A* not available"""
    if target_pos == Vector2.ZERO:
        velocity = Vector2.ZERO
        return
    
    var distance_to_target = global_position.distance_to(target_pos)
    
    if distance_to_target > 16.0:
        var target_direction = (target_pos - global_position).normalized()
        
        # Use wall avoidance if A* not available
        var movement_direction = _get_avoidance_direction(target_direction) if not use_pathfinding else target_direction
        velocity = movement_direction * zombie_data.speed * 0.8
    else:
        zombie_data.state = ZombieData.ZombieState.IDLE
        zombie_data.target_position = Vector2.ZERO
        zombie_data.detected_player = null
        velocity = Vector2.ZERO
        current_path.clear()

func _should_recalculate_path(target_pos: Vector2) -> bool:
    """Determine if path should be recalculated"""
    if path_recalc_timer >= path_recalc_interval:
        return true
    elif current_path.size() == 0:
        return true
    elif last_pathfinding_target.distance_to(target_pos) > 64.0:
        return true
    elif path_index >= current_path.size():
        return true
    return false

func _calculate_new_path(target_pos: Vector2):
    """Calculate new A* path to target"""
    current_path = pathfinding_manager.find_path(global_position, target_pos)
    path_index = 0
    path_recalc_timer = 0.0
    last_pathfinding_target = target_pos
    zombie_data.target_position = target_pos

func _has_line_of_sight_to_player(player) -> bool:
    if not player or not is_instance_valid(player):
        return false
    
    var space_state = get_world_2d().direct_space_state
    if not space_state:
        return false
    
    var query = PhysicsRayQueryParameters2D.create(
        global_position,
        player.global_position
    )
    
    query.collision_mask = PhysicsLayers.WALLS
    query.exclude = [self, player]
    query.hit_from_inside = false
    
    var result = space_state.intersect_ray(query)
    
    return result.is_empty()

func _get_zombie_sight_radius() -> float:
    """Get the current sight radius of the zombie"""
    if zombie_data:
        return zombie_data.sight_range
    return 150.0 # Default fallback value

func _is_player_in_zombie_sight_range(player) -> bool:
    if not player:
        return false
        
    var sight_range = get_node_or_null("SightRange")
    if not sight_range:
        return false
    
    # First check: Area2D overlap
    var in_area = sight_range.overlaps_body(player)
    if not in_area:
        return false
    
    # Second check: Distance validation
    var distance = global_position.distance_to(player.global_position)
    var max_range = _get_zombie_sight_radius()
    
    if distance > max_range:
        return false
    
    return true

func _debug_wall_detection():
    """Test wall detection in all directions including diagonals"""
    var directions = [
        Vector2.RIGHT * 100, # East
        Vector2.LEFT * 100, # West
        Vector2.UP * 100, # North
        Vector2.DOWN * 100, # South
        Vector2(1, 1).normalized() * 100, # Northeast
        Vector2(-1, 1).normalized() * 100, # Northwest
        Vector2(1, -1).normalized() * 100, # Southeast
        Vector2(-1, -1).normalized() * 100 # Southwest
    ]
    
    var direction_names = [
        "RIGHT", "LEFT", "UP", "DOWN",
        "NORTHEAST", "NORTHWEST", "SOUTHEAST", "SOUTHWEST"
    ]
    
    print("=== 8-Direction Wall Detection Debug for ", self.name, " ===")
    
    for i in range(directions.size()):
        var dir_name = direction_names[i]
        var target_pos = global_position + directions[i]
        
        var space_state = get_world_2d().direct_space_state
        var query = PhysicsRayQueryParameters2D.create(global_position, target_pos)
        query.collision_mask = PhysicsLayers.WALLS
        query.exclude = [self]
        
        var result = space_state.intersect_ray(query)
        
        if result.is_empty():
            print("  ", dir_name, ": CLEAR")
        else:
            var distance = global_position.distance_to(result.position)
            print("  ", dir_name, ": BLOCKED by ", result.collider.name, " at distance %.1f" % distance)
    
    print("=== End Wall Detection Debug ===")

func _on_player_entered_zombie_sight(body):
    if body.is_in_group("player"):
        # Validate that player is actually visible (not just in Area2D)
        if _has_line_of_sight_to_player(body):
            zombie_data.detected_player = body
            last_seen_player_position = body.global_position
            is_tracking_player = true

func _physics_process(delta):
    if not zombie_data or is_dead:
        return
    
    # Enhanced player tracking with LOS validation
    if zombie_data.detected_player and is_instance_valid(zombie_data.detected_player):
        var player = zombie_data.detected_player
        var is_in_range = _is_player_in_zombie_sight_range(player)
        var has_los = _has_line_of_sight_to_player(player)
        
        # Only track if BOTH in range AND has LOS
        if is_in_range and has_los:
            last_seen_player_position = player.global_position
            is_tracking_player = true
            
            if zombie_data.state == ZombieData.ZombieState.IDLE:
                zombie_data.state = ZombieData.ZombieState.CHASING
                zombie_data.target_position = player.global_position
        elif is_in_range and not has_los:
            # Player in range but behind wall - keep last known position
            if zombie_data.state == ZombieData.ZombieState.CHASING:
                if zombie_data.target_position.distance_to(last_seen_player_position) > 32.0:
                    zombie_data.target_position = last_seen_player_position
        else:
            # Player completely out of range - clear detection
            zombie_data.detected_player = null
            if zombie_data.target_position == Vector2.ZERO:
                zombie_data.state = ZombieData.ZombieState.IDLE
    
    # Execute movement based on state
    match zombie_data.state:
        ZombieData.ZombieState.IDLE:
            velocity = Vector2.ZERO
            current_path.clear()
        ZombieData.ZombieState.CHASING:
            chase_target(delta)
        ZombieData.ZombieState.DEAD:
            velocity = Vector2.ZERO
            current_path.clear()
    
    move_and_slide()

func _verify_physics_setup():
    """Debug method to check physics layer configuration"""
    var walls = get_tree().get_nodes_in_group("walls")
    if walls.size() == 0:
        print("WARNING: No walls found in scene for zombie: ", self.name)

func chase_target(delta):
    var player = zombie_data.detected_player
    
    # STRICT VALIDATION: Player must be valid, in range, AND have LOS
    if player and is_instance_valid(player):
        var is_in_range = _is_player_in_zombie_sight_range(player)
        var has_los = _has_line_of_sight_to_player(player)
        
        # Priority 1: Direct chase ONLY if both in range AND visible
        if is_in_range and has_los:
            path_recalc_timer += delta
            var target_pos = player.global_position
            
            if zombie_data.target_position.distance_to(target_pos) > 32.0:
                zombie_data.target_position = target_pos
            
            # Execute direct chase
            var direction = (player.global_position - global_position).normalized()
            velocity = direction * zombie_data.speed
    
    # Priority 2: Move to stored target position (exit/last known)
    if zombie_data.target_position != Vector2.ZERO:
        path_recalc_timer += delta
        var distance_to_target = global_position.distance_to(zombie_data.target_position)
        
        if distance_to_target > 16.0:
            if use_pathfinding and pathfinding_manager and _should_recalculate_path(zombie_data.target_position):
                _calculate_new_path(zombie_data.target_position)
            
            if use_pathfinding and current_path.size() > 0:
                _follow_astar_path(delta, false, false, null)
            else:
                var target_direction = (zombie_data.target_position - global_position).normalized()
                var movement_direction = _get_avoidance_direction(target_direction)
                velocity = movement_direction * zombie_data.speed * 0.8
        else:
            zombie_data.state = ZombieData.ZombieState.IDLE
            zombie_data.target_position = Vector2.ZERO
            zombie_data.detected_player = null
            velocity = Vector2.ZERO
            current_path.clear()
    else:
        # No valid target - go idle
        if zombie_data.state != ZombieData.ZombieState.IDLE:
            zombie_data.state = ZombieData.ZombieState.IDLE
            velocity = Vector2.ZERO
            zombie_data.detected_player = null
            current_path.clear()

func _get_avoidance_direction(target_direction: Vector2) -> Vector2:
    var space_state = get_world_2d().direct_space_state
    
    var query = PhysicsRayQueryParameters2D.create(
        global_position,
        global_position + target_direction * 64.0
    )
    query.collision_mask = PhysicsLayers.WALLS
    query.exclude = [self]
    
    var result = space_state.intersect_ray(query)
    
    if result.is_empty():
        return target_direction
    
    var left_direction = target_direction.rotated(-PI / 3)
    var right_direction = target_direction.rotated(PI / 3)
    
    query.to = global_position + left_direction * 64.0
    var left_result = space_state.intersect_ray(query)
    
    query.to = global_position + right_direction * 64.0
    var right_result = space_state.intersect_ray(query)
    
    if left_result.is_empty() and right_result.is_empty():
        return left_direction if randf() > 0.5 else right_direction
    elif left_result.is_empty():
        return left_direction
    elif right_result.is_empty():
        return right_direction
    else:
        return target_direction.rotated(PI / 2)

func _process(delta):
    if is_dead:
        return
        
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
                break

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
    print("Last Seen Player Position: ", last_seen_player_position)
    print("Player Exit Position: ", player_exit_position)
    print("Is Tracking Player: ", is_tracking_player)
    print("Using Pathfinding: ", use_pathfinding)
    print("Current Path Size: ", current_path.size())
    print("Path Index: ", path_index)
    print("Path Recalc Timer: ", "%.2f" % path_recalc_timer)
    
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
    zombie_data.state = ZombieData.ZombieState.DEAD
    
    DebugManager.register_zombie_death()
    
    set_collision_layer_value(2, false)
    set_collision_mask_value(1, false)
    
    var loot_drops = zombie_data.get_loot_drops()
    for drop in loot_drops:
        print("Dropped ", drop["amount"], " of ", drop["item_id"])

    call_deferred("_create_pickups")
    
    await get_tree().create_timer(0.5).timeout
    
    DebugManager.register_zombie_removed()
    queue_free()

func _create_pickups():
    zombie_data.position = global_position
    """Create pickup items - called deferred to avoid physics state conflicts"""
    var pickup_items = zombie_data.create_pickup_items()
    
    for pickup_item in pickup_items:
        var pickup_scene = preload("res://scenes/gameplay/items/item_pickup.tscn")
        var pickup_instance = pickup_scene.instantiate()
        
        pickup_instance.setup(
            pickup_item["item_id"],
            pickup_item["amount"],
            pickup_item["position"]
        )
        
        get_tree().current_scene.add_child(pickup_instance)

func get_health_percentage() -> float:
    """Get health as percentage for UI/AI decisions"""
    return zombie_data.health / float(zombie_data.max_health)

func get_direction_to_player() -> Vector2:
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return Vector2.ZERO
    
    var direction = (player.global_position - global_position).normalized()
    return direction

func show_damage_flash():
    var color_rect = $CollisionShape2D/ColorRect
    if color_rect:
        var original_color = color_rect.color
        color_rect.color = Color.WHITE
        await get_tree().create_timer(0.1).timeout
        color_rect.color = original_color

func set_debug_sight(enabled: bool):
    debug_sight_enabled = enabled
    queue_redraw()

func _can_change_state() -> bool:
    var current_time = Time.get_ticks_msec() / 1000.0
    return current_time - last_state_change_time >= min_state_change_interval

func _change_state(new_state: ZombieData.ZombieState):
    if _can_change_state():
        zombie_data.state = new_state
        last_state_change_time = Time.get_ticks_msec() / 1000.0
        return true
    return false

func force_recalculate_path():
    """Force immediate path recalculation - useful for debug"""
    path_recalc_timer = path_recalc_interval
    current_path.clear()

func get_pathfinding_debug_info() -> Dictionary:
    """Get pathfinding debug information"""
    return {
        "using_pathfinding": use_pathfinding,
        "path_size": current_path.size(),
        "path_index": path_index,
        "recalc_timer": path_recalc_timer,
        "last_target": last_pathfinding_target
    }
