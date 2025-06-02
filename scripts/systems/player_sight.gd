extends Node2D
class_name PlayerSight

@export var sight_range: float = 100.0

var player: Node2D
var sight_area: Area2D
var visible_entities: Array = []
var entities_in_range: Array = [] # Track all entities in sight range
var memory_entities: Dictionary = {} # Track entities in memory with their last known positions
var explored_areas: Dictionary = {}

# debug circle for sight range visualization
@export var debug_enabled: bool = true
@export var debug_zombie_sight_enabled: bool = true # This is the master control
var debug_circle: CircleShape2D

# NEW: Separated debug flags for different systems
@export var debug_los_enabled: bool = false # Line of Sight debug logs
@export var debug_sightrange_enabled: bool = false # Area2D sight range signal logs
@export var debug_state_enabled: bool = false # State change logs
@export var debug_memory_enabled: bool = false # Memory system logs
@export var debug_verbose_enabled: bool = false # Periodic summary logs

# NEW: State tracking for change detection
var entity_los_states: Dictionary = {} # Track last known LOS state for each entity
var entity_visibility_states: Dictionary = {} # Track last known visibility state
var entity_memory_states: Dictionary = {} # Track last known memory state

# DEBOUNCING: Prevent rapid state oscillations (Issue 2 fix)
var entity_last_state_change_time: Dictionary = {} # Track per-entity last change time
var min_state_change_interval: float = 0.1 # 100ms minimum between state changes
var last_signal_process_time: float = 0.0 # Debounce signal processing itself
var min_signal_interval: float = 0.05 # 50ms minimum between signal processing


func _ready():
    add_to_group("player_sight")
    _find_player_and_sight_area()
    _connect_sight_signals()
    # Wait one frame for all zombies to be ready, then initialize visibility
    await get_tree().process_frame
    _initialize_all_zombie_visibility()

func _toggle_all_zombie_sight_debug():
    var zombies = get_tree().get_nodes_in_group("zombies")
    for zombie in zombies:
        if zombie.has_method("set_debug_sight"):
            zombie.set_debug_sight(debug_zombie_sight_enabled)

func _toggle_sight_range_visual():
    queue_redraw() # Trigger _draw() to be called

func _draw():
    if debug_enabled and player and sight_area:
        var player_local_pos = to_local(player.global_position)
        
        # Get the actual radius from the player's SightRange CollisionShape2D
        var actual_radius = _get_sight_area_radius()
        if actual_radius > 0:
            # Draw filled circle (more transparent - was 0.1, now 0.05)
            draw_circle(player_local_pos, actual_radius, Color(0, 1, 0, 0.05))
            # Draw circle outline (more transparent - was 0.8, now 0.4)
            draw_arc(player_local_pos, actual_radius, 0, TAU, 64, Color(0, 1, 0, 0.4), 2.0)

func _get_sight_area_radius() -> float:
    """Get the actual radius from the player's SightRange Area2D"""
    if not sight_area:
        return 0.0
    
    var collision_shape = sight_area.get_node("CollisionShape2D")
    if not collision_shape:
        return 0.0
    
    var shape = collision_shape.shape
    if shape is CircleShape2D:
        return shape.radius
    elif shape is RectangleShape2D:
        # For rectangle shapes, use the larger dimension as radius
        return max(shape.size.x, shape.size.y) / 2.0
    
    # Fallback to the exported variable
    return sight_range

func _initialize_all_zombie_visibility():
    """Initialize visibility for all zombies based on line of sight"""
    var zombies = get_tree().get_nodes_in_group("zombies")
    for zombie in zombies:
        # Check if zombie should be initially visible
        if _is_entity_in_sight_range(zombie) and _has_line_of_sight(zombie):
            if zombie not in visible_entities:
                visible_entities.append(zombie)
            if zombie not in entities_in_range:
                entities_in_range.append(zombie)
            _show_entity(zombie)
            _mark_area_explored(zombie.global_position)
        else:
            _hide_entity_completely(zombie)


func _process(_delta):
    # Only log critical state every 2 seconds, not every frame
    if debug_verbose_enabled and Engine.get_process_frames() % 120 == 0:
        _debug_log_critical_state()
    
    # Clean up invalid entities without forcing positions
    for entity in memory_entities.keys().duplicate():
        if not entity or not is_instance_valid(entity):
            if debug_memory_enabled:
                print("[MEMORY] Invalid entity in memory_entities, removing: %s" % entity)
            memory_entities.erase(entity)
    
    # Only check LOS for currently visible entities - don't touch memory
    for entity in visible_entities.duplicate():
        var has_los = _has_line_of_sight(entity)
        _debug_log_los(entity, has_los, player.global_position.distance_to(entity.global_position))
        
        if not has_los and _can_change_entity_state(entity):
            # Entity lost LOS - move to memory if in explored area
            visible_entities.erase(entity)
            if _is_area_explored(entity.global_position):
                _debug_log_state("Entity lost LOS - adding to memory: %s" % entity.name)
                _add_to_memory(entity)
            else:
                _debug_log_state("Entity lost LOS - hiding (unexplored): %s" % entity.name)
                _hide_entity_completely(entity)
    
    # Separate check for entities in range that aren't visible or in memory
    for entity in entities_in_range.duplicate():
        # Skip entities already handled by visibility or memory systems
        if entity in visible_entities or entity in memory_entities:
            continue
            
        var has_los = _has_line_of_sight(entity)
        _debug_log_los(entity, has_los, player.global_position.distance_to(entity.global_position))
        
        if has_los and _can_change_entity_state(entity):
            # Entity gained LOS - make visible
            visible_entities.append(entity)
            _debug_log_state("Entity gained LOS - making visible: %s" % entity.name)
            _show_entity(entity)
            _mark_area_explored(entity.global_position)
    
    # Redraw debug circle if enabled
    if debug_enabled:
        queue_redraw()

# Signal handlers respect memory system rules
func _on_entity_entered_sight(body):
    if not body.is_in_group("zombies"):
        return
    
    _debug_log_sightrange("ENTERED_SIGHT", body, "Type=%s" % body.get_class())
    
    # Add to entities in range regardless of line of sight
    if body not in entities_in_range:
        entities_in_range.append(body)
        _debug_log_state("Added to entities_in_range: %s (Total: %d)" % [body.name, entities_in_range.size()])
    
    # Don't automatically remove from memory - only if LOS is gained
    var has_los = _has_line_of_sight(body)
    
    if has_los:
        _debug_log_los(body, true, player.global_position.distance_to(body.global_position))
        
        # Entity has LOS - remove from memory and make visible
        if body in memory_entities:
            _debug_log_state("Entity gained LOS - removing from memory: %s" % body.name)
            _remove_from_memory(body)
        
        if body not in visible_entities:
            visible_entities.append(body)
            _debug_log_state("Added to visible_entities: %s (Total: %d)" % [body.name, visible_entities.size()])
            _show_entity(body)
            _mark_area_explored(body.global_position)
    else:
        _debug_log_los(body, false, player.global_position.distance_to(body.global_position))
        # In range but behind wall - don't touch memory, just hide if not already in memory
        if body not in memory_entities:
            _hide_entity_completely(body)

func _on_entity_left_sight(body):
    if not body.is_in_group("zombies"):
        return
    
    _debug_log_sightrange("LEFT_SIGHT", body, "WasVisible=%s WasInMemory=%s" % [body in visible_entities, body in memory_entities])
    
    # Calculate the exact boundary position where zombie left sight range
    var boundary_position = _calculate_sight_boundary_exit_position(body)
    
    # Remove from tracking arrays
    if body in entities_in_range:
        entities_in_range.erase(body)
        _debug_log_state("Removed from entities_in_range: %s (Total: %d)" % [body.name, entities_in_range.size()])
    
    if body in visible_entities:
        visible_entities.erase(body)
        _debug_log_state("Removed from visible_entities: %s (Total: %d)" % [body.name, visible_entities.size()])
    
    # Use boundary position for memory storage
    if body not in memory_entities and _is_area_explored(boundary_position):
        _debug_log_state("Entity left sight - adding to memory at boundary: %s" % body.name)
        memory_entities[body] = boundary_position # Store boundary position, not current position
        _debug_log_memory("ADD_TO_MEMORY", body, boundary_position)
        _add_to_memory(body)
    elif body not in memory_entities:
        _debug_log_state("Entity left sight - hiding (unexplored): %s" % body.name)
        _hide_entity_completely(body)

func _calculate_sight_boundary_exit_position(entity: Node2D) -> Vector2:
    """Calculate where the entity crossed the sight range boundary"""
    if not player or not entity:
        return entity.global_position
    
    var sight_radius = _get_sight_area_radius()
    var player_to_entity = entity.global_position - player.global_position
    var distance_to_entity = player_to_entity.length()
    
    # If entity is still within range, use current position (edge case)
    if distance_to_entity <= sight_radius:
        return entity.global_position
    
    # Calculate the boundary crossing point
    var direction_to_entity = player_to_entity.normalized()
    var boundary_position = player.global_position + (direction_to_entity * sight_radius)
    
    _debug_log_state("Calculated boundary exit position: %s (distance: %.1f)" % [boundary_position, sight_radius])
    return boundary_position


func _add_to_memory(entity):
    if not _can_change_entity_state(entity):
        return false
        
    if not _is_area_explored(entity.global_position):
        return _hide_entity_completely(entity)
    
    # Store the frozen position BEFORE adding to memory
    var frozen_position = entity.global_position
    memory_entities[entity] = frozen_position
    
    # Actually freeze the entity's movement
    if entity.has_method("set_memory_state"):
        entity.set_memory_state(true, frozen_position)
    
    # Visual feedback for memory state
    entity.visible = true
    entity.modulate = Color(0.4, 0.4, 0.4, 1.0)
    
    _debug_log_memory("ADD_TO_MEMORY", entity, frozen_position)
    _record_entity_state_change(entity)
    return true


func _remove_from_memory(entity):
    """Remove entity from memory system - only when gaining LOS"""
    if entity in memory_entities:
        var stored_position = memory_entities[entity]
        _debug_log_memory("REMOVE_FROM_MEMORY", entity, stored_position)
        memory_entities.erase(entity)
        _debug_log_state("Entity removed from memory: %s" % entity.name)

func _validate_memory_system():
    """Debug method to validate memory system consistency"""
    var issues = []
    
    for entity in memory_entities.keys():
        if not entity or not is_instance_valid(entity):
            issues.append("Invalid entity in memory: %s" % entity)
        elif entity in visible_entities:
            issues.append("Entity in both memory and visible: %s" % entity.name)
        elif entity in entities_in_range and _has_line_of_sight(entity):
            issues.append("Entity in memory but has LOS: %s" % entity.name)
    
    for entity in visible_entities:
        if entity in memory_entities:
            issues.append("Entity in both visible and memory: %s" % entity.name)
        elif not _has_line_of_sight(entity):
            issues.append("Visible entity without LOS: %s" % entity.name)
    
    if issues.size() > 0:
        print("Memory system validation failed:")
        for issue in issues:
            print("  - %s" % issue)
    else:
        print("Memory system validation: OK")
    
    return issues.size() == 0


func _find_player_and_sight_area():
    player = get_tree().get_first_node_in_group("player")
    if not player:
        print("PlayerSight: No player found!")
        return
    
    sight_area = player.get_node("SightRange")
    if not sight_area:
        print("PlayerSight: No SightRange found on player!")

func _connect_sight_signals():
    if not sight_area:
        return
    
    sight_area.body_entered.connect(_on_entity_entered_sight)
    sight_area.body_exited.connect(_on_entity_left_sight)

func _is_entity_in_sight_range(entity) -> bool:
    if not sight_area:
        return false
    return sight_area.overlaps_body(entity)

func _has_line_of_sight(target) -> bool:
    if not player or not target:
        return false
    
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.create(
        player.global_position,
        target.global_position
    )
    query.collision_mask = PhysicsLayers.WALLS
    query.exclude = [player]
    
    var result = space_state.intersect_ray(query)
    return result.is_empty()

func _show_entity(entity):
    if not _can_change_entity_state(entity):
        return false
        
    _debug_log_visibility_change(entity, "VISIBLE")
    _record_entity_state_change(entity)
    
    # Make entity fully visible with normal color
    entity.visible = true
    entity.modulate = Color.WHITE
    return true

func _hide_entity_completely(entity):
    if not _can_change_entity_state(entity):
        return false
        
    _debug_log_visibility_change(entity, "HIDDEN")
    _record_entity_state_change(entity)
    
    entity.visible = false
    entity.modulate = Color.WHITE
    return true

func _mark_area_explored(pos: Vector2):
    var grid_pos = Vector2(int(pos.x / 64), int(pos.y / 64))
    explored_areas[grid_pos] = true

func _is_area_explored(pos: Vector2) -> bool:
    var grid_pos = Vector2(int(pos.x / 64), int(pos.y / 64))
    return explored_areas.get(grid_pos, false)

# Enhanced debug helper methods - separated by category

func _debug_log_los(entity: Node, has_los: bool, distance: float = 0.0):
    """Log Line of Sight debug information"""
    if not debug_los_enabled:
        return
        
    var entity_name = entity.name if entity else "NULL"
    var last_los_state = entity_los_states.get(entity, null)
    
    # Only log when LOS state changes
    if last_los_state != has_los:
        entity_los_states[entity] = has_los
        var timestamp = Time.get_time_string_from_system()
        var status = "GAINED" if has_los else "LOST"
        print("[%s] LOS_%s: Entity=%s Distance=%.1f" % [timestamp, status, entity_name, distance])

func _debug_log_sightrange(signal_name: String, entity: Node, extra_info: String = ""):
    """Log SightRange Area2D signal debug information"""
    if not debug_sightrange_enabled:
        return
    var entity_name = entity.name if entity else "NULL"
    var timestamp = Time.get_time_string_from_system()
    print("[%s] SIGHTRANGE_%s: Entity=%s %s" % [timestamp, signal_name, entity_name, extra_info])

func _debug_log_visibility_change(entity: Node, new_state: String):
    """Log visibility state changes"""
    if not debug_state_enabled:
        return
        
    var entity_name = entity.name if entity else "NULL"
    var last_visibility_state = entity_visibility_states.get(entity, "UNKNOWN")
    
    # Only log when visibility state changes
    if last_visibility_state != new_state:
        entity_visibility_states[entity] = new_state
        var timestamp = Time.get_time_string_from_system()
        print("[%s] VISIBILITY_CHANGE: Entity=%s %s->%s" % [timestamp, entity_name, last_visibility_state, new_state])

func _debug_log_memory(action: String, entity: Node, position: Vector2 = Vector2.ZERO):
    """Log memory system changes"""
    if not debug_memory_enabled:
        return
        
    var entity_name = entity.name if entity else "NULL"
    var was_in_memory = entity_memory_states.get(entity, false)
    var now_in_memory = (action == "ADD_TO_MEMORY")
    
    # Only log when memory state changes
    if was_in_memory != now_in_memory:
        entity_memory_states[entity] = now_in_memory
        var timestamp = Time.get_time_string_from_system()
        print("[%s] MEMORY_%s: Entity=%s Position=%s" % [timestamp, action, entity_name, position])

func _debug_log_state(message: String):
    """Log general state changes"""
    if not debug_state_enabled:
        return
    var timestamp = Time.get_time_string_from_system()
    print("[%s] STATE: %s" % [timestamp, message])

func _debug_log_critical_state():
    """Log periodic state summary"""
    if not debug_verbose_enabled:
        return
    var timestamp = Time.get_time_string_from_system()
    print("[%s] STATE_SUMMARY: InRange=%d Visible=%d Memory=%d" % [
        timestamp, entities_in_range.size(), visible_entities.size(), memory_entities.size()
    ])

func reset_debug_state_tracking():
    """Reset all debug state tracking - useful when debugging state corruption"""
    entity_los_states.clear()
    entity_visibility_states.clear()
    entity_memory_states.clear()
    print("Debug state tracking reset")

# Debug method to check system status
func get_debug_info() -> Dictionary:
    return {
        "entities_in_range": entities_in_range.size(),
        "visible_entities": visible_entities.size(),
        "memory_entities": memory_entities.size(),
        "explored_areas": explored_areas.size()
    }

func _can_change_entity_state(entity: Node2D) -> bool:
    """Check if enough time has passed since last state change for this entity"""
    if not entity:
        return false
        
    var current_time = Time.get_ticks_msec() / 1000.0
    var last_change = entity_last_state_change_time.get(entity, 0.0)
    
    return current_time - last_change >= min_state_change_interval

func _record_entity_state_change(entity: Node2D):
    """Record that this entity just had a state change"""
    if entity:
        entity_last_state_change_time[entity] = Time.get_ticks_msec() / 1000.0

func _can_process_signals() -> bool:
    """Check if enough time has passed since last signal processing"""
    var current_time = Time.get_ticks_msec() / 1000.0
    return current_time - last_signal_process_time >= min_signal_interval

func _record_signal_processed():
    """Record that we just processed signals"""
    last_signal_process_time = Time.get_ticks_msec() / 1000.0

# Deferred signal handlers

func _handle_entity_entered(body):
    """Deferred handler for entity entered sight - prevents race conditions"""
    if not body or not is_instance_valid(body):
        return
        
    _debug_log_sightrange("ENTERED_SIGHT", body, "Type=%s" % body.get_class())
    
    # Add to entities in range regardless of line of sight
    if body not in entities_in_range:
        entities_in_range.append(body)
        _debug_log_state("Added to entities_in_range: %s (Total: %d)" % [body.name, entities_in_range.size()])
    
    # Remove from memory if it was there
    _remove_from_memory(body)
    
    # Only make visible if there's line of sight AND debouncing allows
    if _has_line_of_sight(body):
        _debug_log_los(body, true, player.global_position.distance_to(body.global_position))
        if body not in visible_entities and _can_change_entity_state(body):
            visible_entities.append(body)
            _debug_log_state("Added to visible_entities: %s (Total: %d)" % [body.name, visible_entities.size()])
            _show_entity(body)
            _mark_area_explored(body.global_position)
    else:
        _debug_log_los(body, false, player.global_position.distance_to(body.global_position))
        # In range but behind wall - hide it (but don't add to memory yet)
        _hide_entity_completely(body)

func _handle_entity_left(body):
    """Deferred handler for entity left sight - prevents race conditions"""
    if not body or not is_instance_valid(body):
        return
        
    _debug_log_sightrange("LEFT_SIGHT", body, "WasVisible=%s WasInMemory=%s" % [body in visible_entities, body in memory_entities])
    
    # Store current position before removing from tracking
    var last_position = body.global_position
    
    # Remove from both tracking arrays
    if body in entities_in_range:
        entities_in_range.erase(body)
        _debug_log_state("Removed from entities_in_range: %s (Total: %d)" % [body.name, entities_in_range.size()])
    if body in visible_entities:
        visible_entities.erase(body)
        _debug_log_state("Removed from visible_entities: %s (Total: %d)" % [body.name, visible_entities.size()])
    
    # Add to memory if area was explored AND debouncing allows, otherwise hide completely
    if _is_area_explored(last_position):
        memory_entities[body] = last_position
        _debug_log_memory("ADD_TO_MEMORY", body, last_position)
        _add_to_memory(body)
    else:
        _debug_log_state("Hiding entity (not in explored area): %s" % body.name)
        _hide_entity_completely(body)


# Add cleanup method for debouncing data
func cleanup_entity_debouncing_data(entity: Node2D):
    """Clean up debouncing data when entity is removed"""
    entity_last_state_change_time.erase(entity)
    entity_los_states.erase(entity)
    entity_visibility_states.erase(entity)
    entity_memory_states.erase(entity)
