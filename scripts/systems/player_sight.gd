extends Node2D
class_name PlayerSight

@export var sight_range: float = 500.0

var player: Node2D
var sight_area: Area2D
var visible_entities: Array = []
var entities_in_range: Array = [] # Track all entities in sight range
var explored_areas: Dictionary = {}

# VISUAL MEMORY SYSTEM - Pure data storage without entity control
var memory_data: Dictionary = {} # zombie_id -> {position: Vector2, timestamp: float}
var memory_markers: Dictionary = {} # zombie_id -> memory_marker_node

# DEBUG FLAGS - BUG-005 PlayerSight Debug System (synergizes with zombie.gd debug flags)
@export_group("Debug Configuration")
@export var debug_enabled: bool = true
## Master debug toggle - controls system-level logging (init, setup, errors)
## Example: "[PLAYER_SIGHT] SYSTEM_INIT: PlayerSight initialized - Sight range: 500.0, Found 12 zombies"
# ✅ Always on
@export var debug_sight_visualization: bool = true
## Visual sight range circles drawn around player (green translucent circles)
## Shows: sight radius overlay, memory marker positions if enabled
## Example: Green circle with 500px radius around player showing detection area
# ✅ Visual feedback
@export var debug_entity_tracking: bool = true
## Entity list management - logs when zombies enter/leave visible_entities and entities_in_range arrays
## Example: "📊 [PLAYER_SIGHT] ENTITY_VISIBLE_ADD: Added WALKER_123 to visible_entities (Total: 5)"
# ✅ Essential for BUG-005 analysis
@export var debug_los_validation: bool = true
## Line of sight validation - logs LOS checks from player perspective
## Example: "👁️ [PLAYER_SIGHT] LOS_CLEAR: WALKER_123: Clear LOS at distance 245.3"
# ❌ Too spammy initially
@export var debug_signal_processing: bool = true
## Area2D signal tracking - logs when zombies enter/exit player sight Area2D
## Example: "🎯 [PLAYER_SIGHT] SIGNAL_ENTERED_SIGHT: WALKER_123 entered sight range (Distance: 234.5)"
# ✅ Critical for BUG-005 signal flow analysis
@export var debug_memory_operations: bool = true
## Memory system operations - logs memory data storage, marker creation/destruction
## Example: "🧠 [PLAYER_SIGHT] MEMORY_STORED: WALKER_123 memory stored at: (456.7, -234.1)"
# ✅ Essential for memory system validation
@export var debug_state_transitions: bool = true
## State change tracking - logs when zombies transition between VISIBLE/MEMORY/HIDDEN states
## Example: "🔄 [PLAYER_SIGHT] STATE_TRANSITION: WALKER_123: VISIBLE -> MEMORY (lost LOS)"
# ✅ Critical for BUG-005 state analysis
@export var debug_boundary_calculations: bool = true
## Sight boundary position calculations - logs precise exit position calculations
## Example: "📐 [PLAYER_SIGHT] BOUNDARY_CALCULATED: WALKER_123 exit position: (234.5, -456.7)"
# ✅ Essential for memory positioning accuracy
@export var debug_exploration_system: bool = true
## Area exploration tracking - logs when areas are marked as explored
## Example: "🗺️ [PLAYER_SIGHT] EXPLORATION_MARKED: Area (12, -8) marked as explored - Total areas: 45"
# ❌ Moderate spam
@export var debug_performance_monitoring: bool = true
## Performance metrics - tracks LOS check frequency, entity counts, processing times
## Example: "⚡ [PLAYER_SIGHT] PERF_LOS_CHECKS: Performed 8 visible LOS checks, 3 range LOS checks"
# ✅ Important for optimization
@export var debug_validation_checks: bool = true
## System integrity validation - memory system consistency, marker validation
## Example: "✅ [PLAYER_SIGHT] VALIDATION_PASSED: Memory system validation passed - 3 entries"
# ❌ Only for debugging issues
# Enhanced debug state tracking for change detection
var entity_los_states: Dictionary = {} # Track last known LOS state for each entity
var entity_visibility_states: Dictionary = {} # Track last known visibility state

# DEBOUNCING: Prevent rapid state oscillations
var entity_last_state_change_time: Dictionary = {} # Track per-entity last change time
var min_state_change_interval: float = 0.1 # 100ms minimum between state changes
var last_signal_process_time: float = 0.0
var min_signal_interval: float = 0.05 # 50ms minimum between signal processing

func _ready():
    add_to_group("player_sight")
    
    _debug_log_system("INIT", "PlayerSight initializing...")
    
    _find_player_and_sight_area()
    _connect_sight_signals()
    _fix_radius_mismatch()

    # Log initialization results
    var zombie_count = get_tree().get_nodes_in_group("zombies").size()
    var sight_radius = _get_sight_area_radius()
    _debug_log_system("INIT", "PlayerSight initialized - Sight range: %.1f, Found %d zombies" % [sight_radius, zombie_count])
    
    # Wait one frame for all zombies to be ready, then initialize visibility
    await get_tree().process_frame
    _initialize_all_zombie_visibility()

func _initialize_all_zombie_visibility():
    """Initialize visibility for all zombies based on line of sight"""
    var zombies = get_tree().get_nodes_in_group("zombies")
    var visible_count = 0
    var hidden_count = 0
    
    _debug_log_system("INIT_VISIBILITY", "Initializing visibility for %d zombies..." % zombies.size())
    
    for zombie in zombies:
        var zombie_id = zombie.zombie_id if "zombie_id" in zombie else zombie.name
        
        # Check if zombie should be initially visible
        if _is_entity_in_sight_range(zombie) and _has_line_of_sight(zombie):
            if zombie not in visible_entities:
                visible_entities.append(zombie)
                _debug_log_entity_tracking("INIT_VISIBLE", "Added %s to visible_entities" % zombie_id)
            if zombie not in entities_in_range:
                entities_in_range.append(zombie)
            _show_entity(zombie)
            _mark_area_explored(zombie.global_position)
            visible_count += 1
        else:
            _hide_entity_completely(zombie)
            hidden_count += 1
    
    _debug_log_system("INIT_COMPLETE", "Visibility initialization complete: %d visible, %d hidden" % [visible_count, hidden_count])


# ============================================================================
# VISUAL MEMORY SYSTEM - Using actual zombie visuals
# ============================================================================

func _store_in_memory(zombie_id: String, position: Vector2, zombie_entity: Node2D = null):
    """Store zombie memory data and create visual marker using zombie appearance"""
   # if not _is_area_explored(position):
    #    _debug_log_memory_operations("REJECTED", "%s memory rejected - area not explored" % zombie_id)
     #   return false
    
    # Store pure data - no entity control
    memory_data[zombie_id] = {
        "position": position,
        "timestamp": Time.get_ticks_msec() / 1000.0
    }
    
    # Create visual marker using zombie's actual appearance
    _create_memory_marker_from_zombie(zombie_id, position, zombie_entity)
    
    # Update zombie's debug label to show memory status
    if zombie_entity and zombie_entity.has_method("_update_debug_label"):
        zombie_entity._update_debug_label()
    
    _debug_log_memory_operations("STORED", "%s memory stored at: %s" % [zombie_id, position])
    return true

func _remove_from_memory(zombie_id: String, zombie_entity: Node2D = null):
    """Remove zombie from memory and destroy visual marker"""
    if zombie_id in memory_data:
        var stored_data = memory_data[zombie_id]
        memory_data.erase(zombie_id)
        
        _destroy_memory_marker(zombie_id)
        
        # Update zombie's debug label to remove memory status
        if zombie_entity and zombie_entity.has_method("_update_debug_label"):
            zombie_entity._update_debug_label()
        
        _debug_log_memory_operations("REMOVED", "%s memory removed (was at: %s)" % [
            zombie_id, stored_data.position
        ])
    else:
        _debug_log_memory_operations("NOT_FOUND", "%s memory removal attempted but not found" % zombie_id)

func _create_memory_marker_from_zombie(zombie_id: String, position: Vector2, zombie_entity: Node2D):
    """Create visual memory marker using zombie's actual appearance"""
    # Remove existing marker if present
    _destroy_memory_marker(zombie_id)
    
    if not zombie_entity:
        _debug_log_memory_operations("ERROR", "Cannot create memory marker - no zombie entity provided")
        return
    
    # Create new marker node
    var marker = Node2D.new()
    marker.name = "MemoryMarker_%s" % zombie_id
    marker.global_position = position
    
    # Clone the zombie's visual representation - using the actual ColorRect system
    var zombie_color_rect = zombie_entity.get_node_or_null("CollisionShape2D/ColorRect")
    if zombie_color_rect:
        # Create a memory version of the zombie's ColorRect
        var memory_rect = ColorRect.new()
        memory_rect.size = zombie_color_rect.size
        memory_rect.position = zombie_color_rect.position
        
        # Get the original color and make it darker/semi-transparent for memory
        var original_color = zombie_color_rect.color
        var memory_color = Color(
            original_color.r * 0.3, # Darken red component
            original_color.g * 0.3, # Darken green component
            original_color.b * 0.3, # Darken blue component
            0.7 # Semi-transparent
        )
        memory_rect.color = memory_color
        
        marker.add_child(memory_rect)
        
        _debug_log_memory_operations("MARKER_CREATED", "%s visual marker created using zombie ColorRect appearance - Color: %s -> %s" % [
            zombie_id, original_color, memory_color
        ])
    else:
        # Fallback: create a simple darkened rect if ColorRect not found
        var fallback_rect = ColorRect.new()
        fallback_rect.size = Vector2(20, 20)
        fallback_rect.position = Vector2(-10, -10)
        fallback_rect.color = Color(0.3, 0.3, 0.3, 0.7)
        marker.add_child(fallback_rect)
        
        _debug_log_memory_operations("FALLBACK", "Using fallback visual for %s - zombie ColorRect not found at expected path" % zombie_id)
    
    # Add to scene
    get_tree().current_scene.add_child(marker)
    memory_markers[zombie_id] = marker
    
    _debug_log_memory_operations("MARKER_CREATED", "%s visual marker created at: %s using zombie ColorRect appearance" % [zombie_id, position])

func _destroy_memory_marker(zombie_id: String):
    """Destroy visual memory marker"""
    if zombie_id in memory_markers:
        var marker = memory_markers[zombie_id]
        if marker and is_instance_valid(marker):
            marker.queue_free()
        memory_markers.erase(zombie_id)
        
        _debug_log_memory_operations("MARKER_DESTROYED", "%s visual marker destroyed" % zombie_id)

func _update_memory_markers():
    """Update memory markers based on player proximity and LOS"""
    for zombie_id in memory_data.keys():
        var memory_info = memory_data[zombie_id]
        var marker = memory_markers.get(zombie_id)
        
        if not marker or not is_instance_valid(marker):
            # Try to find the zombie entity to recreate marker
            var zombie_entity = _find_zombie_by_id(zombie_id)
            _create_memory_marker_from_zombie(zombie_id, memory_info.position, zombie_entity)
            continue
        
        # Check if player can see the memory position
        var distance_to_memory = player.global_position.distance_to(memory_info.position)
        var in_sight_range = distance_to_memory <= sight_range
        var has_los_to_memory = _has_line_of_sight_to_position(memory_info.position)
        
        # Show/hide marker based on visibility
        if in_sight_range and has_los_to_memory:
            marker.visible = true
            marker.modulate.a = 0.7 # Full memory visibility
        elif in_sight_range:
            marker.visible = true
            marker.modulate.a = 0.3 # Reduced visibility (behind wall)
        else:
            marker.visible = false # Out of range

func _find_zombie_by_id(zombie_id: String) -> Node2D:
    """Find zombie entity by ID"""
    var zombies = get_tree().get_nodes_in_group("zombies")
    for zombie in zombies:
        if zombie.has_method("get") and zombie.zombie_id == zombie_id:
            return zombie
    return null

func _cleanup_invalid_memory_data():
    """Clean up invalid memory data and markers"""
    var cleaned_count = 0
    
    # Clean up memory data without valid markers
    for zombie_id in memory_data.keys().duplicate():
        var marker = memory_markers.get(zombie_id)
        if marker and not is_instance_valid(marker):
            memory_data.erase(zombie_id)
            memory_markers.erase(zombie_id)
            cleaned_count += 1
    
    if cleaned_count > 0:
        _debug_log_system("CLEANUP", "Cleaned %d invalid memory entries" % cleaned_count)

# ============================================================================
# ENTITY VISIBILITY CONTROL - Modified for memory-first approach
# ============================================================================

func _show_entity(entity):
    """Show entity - purely visual, no state control"""
    var entity_id = entity.zombie_id if "zombie_id" in entity else entity.name
    
    if not _can_change_entity_state(entity):
        _debug_log_state_transitions("REJECTED", "%s show rejected - state change too recent" % entity_id)
        return false
        
    _debug_log_state_transitions("SHOW", "%s made visible" % entity_id)
    _record_entity_state_change(entity)
    
    # Make entity fully visible with normal color - NO STATE CONTROL
    entity.visible = true
    entity.modulate = Color.WHITE
    return true

func _hide_entity_completely(entity):
    """Hide entity - ONLY used for initial setup, never after first detection"""
    var entity_id = entity.zombie_id if "zombie_id" in entity else entity.name
    
    # Check if this zombie has ever been detected (has memory or is currently visible)
    var ever_detected = (entity_id in memory_data) or (entity in visible_entities)
    
    if ever_detected:
        _debug_log_state_transitions("REJECTED", "%s hide rejected - zombie has been detected before, moving to memory instead" % entity_id)
        # Once detected, zombie should go to memory, not be hidden
        _store_in_memory(entity_id, entity.global_position, entity)
        return false
    
    if not _can_change_entity_state(entity):
        _debug_log_state_transitions("REJECTED", "%s hide rejected - state change too recent" % entity_id)
        return false
        
    _debug_log_state_transitions("HIDE", "%s hidden completely (initial setup only)" % entity_id)
    _record_entity_state_change(entity)
    
    # Hide entity - NO STATE CONTROL
    entity.visible = false
    entity.modulate = Color.WHITE
    return true

# ============================================================================
# SIGNAL HANDLERS - Updated for memory-first system
# ============================================================================

func _on_entity_entered_sight(body):
    """Enhanced entity entered sight handler"""
    if not body.is_in_group("zombies"):
        return
    
    var entity_id = body.zombie_id if "zombie_id" in body else body.name
    var distance = player.global_position.distance_to(body.global_position) if player else 0.0
    
    _debug_log_signal_processing("ENTERED_SIGHT", "%s entered sight range (Distance: %.1f)" % [entity_id, distance])
    
    # Add to entities in range regardless of line of sight
    if body not in entities_in_range:
        entities_in_range.append(body)
        _debug_log_entity_tracking("RANGE_ADD", "Added %s to entities_in_range (Total: %d)" % [entity_id, entities_in_range.size()])
    
    # Check if entity has LOS
    var has_los = _has_line_of_sight(body)
    
    if has_los:
        _debug_log_los_validation("ENTERED_WITH_LOS", "%s has clear LOS at distance %.1f" % [entity_id, distance])
        
        # Remove from memory if it exists (zombie is now visible)
        if entity_id in memory_data:
            _debug_log_state_transitions("TRANSITION", "%s: MEMORY -> VISIBLE (gained LOS on entry)" % entity_id)
            _remove_from_memory(entity_id, body)
        
        if body not in visible_entities:
            visible_entities.append(body)
            _debug_log_entity_tracking("VISIBLE_ADD", "Added %s to visible_entities (Total: %d)" % [entity_id, visible_entities.size()])
            _show_entity(body)
            _mark_area_explored(body.global_position)
    else:
        _debug_log_los_validation("ENTERED_NO_LOS", "%s in range but no LOS - blocked by wall" % entity_id)
        # In range but behind wall - check if ever detected before
        var ever_detected = (entity_id in memory_data) or (body in visible_entities)
        if ever_detected:
            # Move to memory instead of hiding
            _store_in_memory(entity_id, body.global_position, body)
        else:
            # First time detection but behind wall - hide for now
            _hide_entity_completely(body)

func _on_entity_left_sight(body):
    """Enhanced entity left sight handler with boundary position tracking"""
    if not body.is_in_group("zombies"):
        return
    
    var entity_id = body.zombie_id if "zombie_id" in body else body.name
    var was_visible = body in visible_entities
    
    _debug_log_signal_processing("LEFT_SIGHT", "%s left sight range (WasVisible=%s)" % [entity_id, was_visible])
    
    # Calculate the exact boundary position where entity left sight range
    var boundary_position = _calculate_sight_boundary_exit_position(body)
    
    # Remove from tracking arrays
    if body in entities_in_range:
        entities_in_range.erase(body)
        _debug_log_entity_tracking("RANGE_REMOVE", "Removed %s from entities_in_range (Total: %d)" % [entity_id, entities_in_range.size()])
    
    if body in visible_entities:
        visible_entities.erase(body)
        _debug_log_entity_tracking("VISIBLE_REMOVE", "Removed %s from visible_entities (Total: %d)" % [entity_id, visible_entities.size()])
    
    # Store in memory if area is explored (zombies are never truly hidden once detected)
    if _is_area_explored(boundary_position):
        _debug_log_state_transitions("TRANSITION", "%s: VISIBLE -> MEMORY (left sight at boundary)" % entity_id)
        _store_in_memory(entity_id, boundary_position, body)
    else:
        # Even unexplored areas get memory now, not hidden
        _debug_log_state_transitions("TRANSITION", "%s: VISIBLE -> MEMORY (unexplored area)" % entity_id)
        _store_in_memory(entity_id, boundary_position, body)

# ============================================================================
# VISUAL DEBUG SYSTEM - Removed circles
# ============================================================================

func _draw():
    """Enhanced debug visualization - removed memory circles"""
    if debug_sight_visualization and player and sight_area:
        var player_local_pos = to_local(player.global_position)
        var actual_radius = _get_sight_area_radius()
        
        if actual_radius > 0:
            # Draw sight range circle only
            draw_circle(player_local_pos, actual_radius, Color(0, 1, 0, 0.05))
            draw_arc(player_local_pos, actual_radius, 0, TAU, 64, Color(0, 1, 0, 0.4), 2.0)
        
        # Memory positions are now represented by actual zombie sprites, no circles needed

# ============================================================================
# MODIFIED PROCESS LOOP - Updated for memory-first approach
# ============================================================================

func _process(_delta):
    # Performance monitoring
    if debug_performance_monitoring and Engine.get_process_frames() % 120 == 0: # Every 2 seconds
        _debug_log_performance("PERIODIC_SUMMARY", "InRange=%d Visible=%d Memory=%d Explored=%d" % [
            entities_in_range.size(), visible_entities.size(), memory_data.size(), explored_areas.size()
        ])
    
    # Clean up invalid memory data
    _cleanup_invalid_memory_data()
    
    # Update memory marker positions and visibility
    _update_memory_markers()
    
    # Only check LOS for currently visible entities
    var los_checks_performed = 0
    for entity in visible_entities.duplicate():
        var entity_id = entity.zombie_id if "zombie_id" in entity else entity.name
        var has_los = _has_line_of_sight(entity)
        los_checks_performed += 1
        
        _debug_log_los_validation("VISIBLE_CHECK", "%s: LOS=%s Distance=%.1f" % [
            entity_id, has_los, player.global_position.distance_to(entity.global_position)
        ])
        
        if not has_los and _can_change_entity_state(entity):
            # Entity lost LOS - move to memory (no longer hide once detected)
            visible_entities.erase(entity)
            _debug_log_entity_tracking("LOST_LOS", "Removed %s from visible_entities (Total: %d)" % [entity_id, visible_entities.size()])
            _debug_log_state_transitions("TRANSITION", "%s: VISIBLE -> MEMORY (lost LOS)" % entity_id)
            _store_in_memory(entity_id, entity.global_position, entity)
    
    # Check entities in range that aren't visible
    var range_checks_performed = 0
    for entity in entities_in_range.duplicate():
        # Skip entities already handled by visibility system
        if entity in visible_entities:
            continue
            
        var entity_id = entity.zombie_id if "zombie_id" in entity else entity.name
        var has_los = _has_line_of_sight(entity)
        range_checks_performed += 1
        
        _debug_log_los_validation("RANGE_CHECK", "%s: LOS=%s Distance=%.1f" % [
            entity_id, has_los, player.global_position.distance_to(entity.global_position)
        ])
        
        if has_los and _can_change_entity_state(entity):
            # Entity gained LOS - make visible and remove from memory
            visible_entities.append(entity)
            _debug_log_entity_tracking("GAINED_LOS", "Added %s to visible_entities (Total: %d)" % [entity_id, visible_entities.size()])
            _debug_log_state_transitions("TRANSITION", "%s: RANGE -> VISIBLE (gained LOS)" % entity_id)
            _show_entity(entity)
            _mark_area_explored(entity.global_position)
            
            # Remove from memory if it exists
            if entity_id in memory_data:
                _remove_from_memory(entity_id, entity)
    
    # Performance logging
    if debug_performance_monitoring and (los_checks_performed > 0 or range_checks_performed > 0):
        _debug_log_performance("LOS_CHECKS", "Performed %d visible LOS checks, %d range LOS checks" % [
            los_checks_performed, range_checks_performed
        ])
    
    # Redraw debug circle if enabled
    if debug_sight_visualization:
        queue_redraw()

# ============================================================================
# UTILITY METHODS - Enhanced for new memory system
# ============================================================================

func _validate_memory_system():
    """Validate memory system integrity"""
    _debug_log_validation("STARTING", "Beginning memory system validation...")
    
    var issues = []
    var data_entries = memory_data.size()
    var marker_entries = memory_markers.size()
    
    # Check data/marker consistency
    if data_entries != marker_entries:
        issues.append("Memory data count (%d) doesn't match marker count (%d)" % [data_entries, marker_entries])
    
    # Check each memory entry
    for zombie_id in memory_data.keys():
        if zombie_id not in memory_markers:
            issues.append("Memory data exists but no marker for: %s" % zombie_id)
        else:
            var marker = memory_markers[zombie_id]
            if not marker or not is_instance_valid(marker):
                issues.append("Invalid marker for zombie: %s" % zombie_id)
    
    # Check for orphaned markers
    for zombie_id in memory_markers.keys():
        if zombie_id not in memory_data:
            issues.append("Marker exists but no memory data for: %s" % zombie_id)
    
    if issues.size() > 0:
        _debug_log_validation("FAILED", "Memory system validation failed with %d issues:" % issues.size())
        for issue in issues:
            _debug_log_validation("ISSUE", issue)
    else:
        _debug_log_validation("PASSED", "Memory system validation passed - %d entries" % data_entries)
    
    return issues.size() == 0

func get_memory_debug_info() -> Dictionary:
    """Get comprehensive memory system debug info"""
    return {
        "memory_data_count": memory_data.size(),
        "memory_markers_count": memory_markers.size(),
        "visible_entities": visible_entities.size(),
        "entities_in_range": entities_in_range.size(),
        "explored_areas": explored_areas.size(),
        "sight_radius": _get_sight_area_radius()
    }

# ============================================================================
# PRESERVED UTILITY METHODS - Minimal changes
# ============================================================================

func _find_player_and_sight_area():
    """Enhanced player and sight area detection with debug logging"""
    player = get_tree().get_first_node_in_group("player")
    if not player:
        _debug_log_system("ERROR", "No player found in scene!")
        return
    
    _debug_log_system("SETUP", "Player found: %s" % player.name)
    
    sight_area = player.get_node("SightRange")
    if not sight_area:
        _debug_log_system("ERROR", "No SightRange found on player!")
        return
        
    _debug_log_system("SETUP", "SightRange found: collision_mask=%d" % sight_area.collision_mask)

func _connect_sight_signals():
    """Enhanced signal connection with debug logging"""
    if not sight_area:
        _debug_log_system("ERROR", "Cannot connect signals - no sight_area")
        return
    
    if not sight_area.body_entered.is_connected(_on_entity_entered_sight):
        sight_area.body_entered.connect(_on_entity_entered_sight)
        _debug_log_system("SETUP", "Connected body_entered signal")
    
    if not sight_area.body_exited.is_connected(_on_entity_left_sight):
        sight_area.body_exited.connect(_on_entity_left_sight)
        _debug_log_system("SETUP", "Connected body_exited signal")

func _fix_radius_mismatch():
    """Auto-correct Area2D radius to match exported sight_range"""
    if not sight_area:
        return
        
    var collision_shape = sight_area.get_node("CollisionShape2D")
    if collision_shape and collision_shape.shape is CircleShape2D:
        var current_radius = collision_shape.shape.radius
        if abs(current_radius - sight_range) > 1.0:
            collision_shape.shape.radius = sight_range
            _debug_log_system("AUTO_FIX", "Area2D radius corrected from %.1f to %.1f" % [current_radius, sight_range])

func _get_sight_area_radius() -> float:
    """Get the actual radius from the player's SightRange Area2D"""
    if not sight_area:
        return sight_range
    
    var collision_shape = sight_area.get_node("CollisionShape2D")
    if not collision_shape:
        return sight_range
    
    var shape = collision_shape.shape
    if shape is CircleShape2D:
        return shape.radius
    
    return sight_range

func _is_entity_in_sight_range(entity) -> bool:
    """Check if entity is in sight range"""
    if not sight_area:
        return false
    return sight_area.overlaps_body(entity)

func _has_line_of_sight(target) -> bool:
    """Enhanced LOS check with debug logging"""
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
    var has_los = result.is_empty()
    var distance = player.global_position.distance_to(target.global_position)
    var target_id = target.zombie_id if "zombie_id" in target else target.name
    
    if not has_los:
        var blocker_name = result.collider.name if result.collider else "UNKNOWN"
        _debug_log_los_validation("BLOCKED", "%s: No LOS - blocked by %s at distance %.1f" % [
            target_id, blocker_name, distance
        ])
    else:
        _debug_log_los_validation("CLEAR", "%s: Clear LOS at distance %.1f" % [target_id, distance])
    
    return has_los

func _has_line_of_sight_to_position(target_position: Vector2) -> bool:
    """Check line of sight to a specific position"""
    if not player:
        return false
    
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.create(
        player.global_position,
        target_position
    )
    query.collision_mask = PhysicsLayers.WALLS
    query.exclude = [player]
    
    var result = space_state.intersect_ray(query)
    return result.is_empty()

func _mark_area_explored(pos: Vector2):
    """Mark area as explored"""
    var grid_pos = Vector2(int(pos.x / 64), int(pos.y / 64))
    
    if not explored_areas.get(grid_pos, false):
        explored_areas[grid_pos] = true
        _debug_log_exploration_system("MARKED", "Area (%d, %d) marked as explored - Total areas: %d" % [
            grid_pos.x, grid_pos.y, explored_areas.size()
        ])

func _is_area_explored(pos: Vector2) -> bool:
    """Check if area is explored"""
    var grid_pos = Vector2(int(pos.x / 64), int(pos.y / 64))
    return explored_areas.get(grid_pos, false)

func _calculate_sight_boundary_exit_position(entity: Node2D) -> Vector2:
    """Calculate the position where entity exits the sight boundary"""
    if not player or not entity:
        return entity.global_position if entity else Vector2.ZERO
    
    var player_pos = player.global_position
    var entity_pos = entity.global_position
    var direction = (entity_pos - player_pos).normalized()
    var boundary_pos = player_pos + direction * sight_range
    
    var entity_id = entity.zombie_id if "zombie_id" in entity else entity.name
    _debug_log_boundary_calculations("CALCULATED", "%s exit position: %s" % [entity_id, boundary_pos])
    
    return boundary_pos

func _can_change_entity_state(entity: Node2D) -> bool:
    """Check if enough time has passed since last state change"""
    if not entity:
        return false
        
    var current_time = Time.get_ticks_msec() / 1000.0
    var last_change = entity_last_state_change_time.get(entity, 0.0)
    return current_time - last_change >= min_state_change_interval

func _record_entity_state_change(entity: Node2D):
    """Record that this entity just had a state change"""
    if entity:
        entity_last_state_change_time[entity] = Time.get_ticks_msec() / 1000.0


# ============================================================================
# DEBUG LOGGING SYSTEM
# ============================================================================

func _debug_log_system(category: String, message: String):
    if debug_enabled:
        DebugManager.log_debug_categorized("ai", "[PLAYER_SIGHT] SYSTEM_%s: %s" % [category, message])

func _debug_log_entity_tracking(category: String, message: String):
    if debug_entity_tracking:
        DebugManager.log_debug_categorized("ai", "📊 [PLAYER_SIGHT] ENTITY_%s: %s" % [category, message])

func _debug_log_los_validation(category: String, message: String):
    if debug_los_validation:
        DebugManager.log_debug_categorized("ai", "👁️ [PLAYER_SIGHT] LOS_%s: %s" % [category, message])

func _debug_log_signal_processing(category: String, message: String):
    if debug_signal_processing:
        DebugManager.log_debug_categorized("ai", "🎯 [PLAYER_SIGHT] SIGNAL_%s: %s" % [category, message])

func _debug_log_memory_operations(category: String, message: String):
    if debug_memory_operations:
        DebugManager.log_debug_categorized("ai", "🧠 [PLAYER_SIGHT] MEMORY_%s: %s" % [category, message])

func _debug_log_state_transitions(category: String, message: String):
    if debug_state_transitions:
        DebugManager.log_debug_categorized("ai", "🔄 [PLAYER_SIGHT] STATE_%s: %s" % [category, message])

func _debug_log_boundary_calculations(category: String, message: String):
    if debug_boundary_calculations:
        DebugManager.log_debug_categorized("ai", "📐 [PLAYER_SIGHT] BOUNDARY_%s: %s" % [category, message])

func _debug_log_exploration_system(category: String, message: String):
    if debug_exploration_system:
        DebugManager.log_debug_categorized("ai", "🗺️ [PLAYER_SIGHT] EXPLORATION_%s: %s" % [category, message])

func _debug_log_performance(category: String, message: String):
    if debug_performance_monitoring:
        DebugManager.log_debug_categorized("ai", "⚡ [PLAYER_SIGHT] PERF_%s: %s" % [category, message])

func _debug_log_validation(category: String, message: String):
    if debug_validation_checks:
        DebugManager.log_debug_categorized("ai", "✅ [PLAYER_SIGHT] VALIDATION_%s: %s" % [category, message])

# ============================================================================
# LEGACY COMPATIBILITY (for DebugManager integration)
# ============================================================================

var debug_zombie_sight_enabled: bool = true:
    get:
        return debug_sight_visualization
    set(value):
        debug_sight_visualization = value

var debug_state_enabled: bool:
    get:
        return debug_state_transitions
    set(value):
        debug_state_transitions = value

var debug_sightrange_enabled: bool:
    get:
        return debug_signal_processing
    set(value):
        debug_signal_processing = value

var debug_los_enabled: bool:
    get:
        return debug_los_validation
    set(value):
        debug_los_validation = value

var debug_memory_enabled: bool:
    get:
        return debug_memory_operations
    set(value):
        debug_memory_operations = value

var debug_verbose_enabled: bool:
    get:
        return debug_performance_monitoring
    set(value):
        debug_performance_monitoring = value
