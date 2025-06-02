# scripts/debug/debug_manager.gd
# Debug key bindings:
# F1: Cycle zombie debug profiles (operates on zombie.gd flags)
# F2: Print BUG-005 debug statistics
# F3: Memory monitoring toggle
# F4: Collision debug toggle  
# F5: AI debug toggle
# F6: Player sight range visualization toggle
# F7: Zombie sight range visualization toggle
# F8: Debug all zombie states
# F9: Vision state logging toggle
# F10: Vision signal logging toggle
# F11: Vision memory logging toggle
# F12: All vision logging toggle
# ESC: Reset vision debug state tracking

extends Node

# GLOBAL DEBUG TOGGLES (NOT zombie-specific)
var memory_monitoring: bool = false
var collision_debug: bool = true
var ai_debug: bool = true
var physics_debug: bool = true
@export var show_debug_health: bool = true

# AI Debug counters
var zombie_count: int = 0
var zombies_killed: int = 0
var bullets_fired: int = 0
var bullets_hit: int = 0

# BUG-005 Debug Statistics (aggregated from all zombies)
var zombie_debug_stats: Dictionary = {
    "memory_mode_activations": 0,
    "los_checks_per_second": 0,
    "position_updates_per_second": 0,
    "state_transitions_per_second": 0,
    "pathfinding_recalculations": 0
}

# Statistics reset timer
var stats_reset_timer: float = 0.0
var stats_reset_interval: float = 10.0 # Reset counters every 10 seconds

func _ready():
    print("🔧 DebugManager initialized - Zombie debug flags managed per-zombie in zombie.gd")

func _process(delta):
    # Reset statistics periodically for accurate per-second measurements
    stats_reset_timer += delta
    if stats_reset_timer >= stats_reset_interval:
        _reset_per_second_stats()
        stats_reset_timer = 0.0
    
    # Monitor memory if enabled
    monitor_memory()

func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F1:
                toggle_zombie_debug_profiles()
            KEY_F2:
                print_zombie_debug_stats()
            KEY_F3:
                toggle_memory_monitoring()
            KEY_F4:
                toggle_collision_debug()
            KEY_F5:
                toggle_ai_debug()
            KEY_F6:
                toggle_player_sight_range_debug()
            KEY_F7:
                toggle_zombie_sight_range_debug()
            KEY_F8:
                debug_all_zombie_states()
            KEY_F9:
                toggle_vision_state_logging()
            KEY_F10:
                toggle_vision_signal_logging()
            KEY_F11:
                toggle_vision_memory_logging()
            KEY_F12:
                toggle_all_vision_logging()
            KEY_ESCAPE:
                reset_vision_debug_state()

# ============================================================================
# ZOMBIE DEBUG LOGGING SYSTEM - Routes to individual zombie flags
# ============================================================================

func log_zombie_debug(zombie_id: String, category: String, message: String):
    """Route zombie debug through individual zombie settings - NO local flags"""
    if not ai_debug:
        return # Global AI debug disabled
    
    # Get the zombie instance to check its individual debug flags
    var zombie = _find_zombie_by_id(zombie_id)
    if not zombie:
        return
    
    var formatted_message = "[%s] %s: %s" % [zombie_id, category, message]
    var should_log = false
    
    # Check individual zombie debug flags (single source of truth)
    if category.begins_with("SYSTEM_") and zombie.debug_enabled:
        should_log = true
        formatted_message = "🧟 " + formatted_message
    elif category.begins_with("MOVEMENT_") and zombie.debug_movement_enabled:
        should_log = true
        formatted_message = "🏃 " + formatted_message
        _increment_debug_stat("position_updates_per_second")
    elif category.begins_with("LOS_") and zombie.debug_los_enabled:
        should_log = true
        formatted_message = "👁️ " + formatted_message
        _increment_debug_stat("los_checks_per_second")
    elif category.begins_with("STATE_") and zombie.debug_state_transitions_enabled:
        should_log = true
        formatted_message = "🔄 " + formatted_message
        _increment_debug_stat("state_transitions_per_second")
    elif category.begins_with("POSITION_") and zombie.debug_position_updates_enabled:
        should_log = true
        formatted_message = "📍 " + formatted_message
        _increment_debug_stat("position_updates_per_second")
    elif category.begins_with("MEMORY_") and zombie.debug_memory_system_enabled:
        should_log = true
        formatted_message = "🧠 " + formatted_message
        if "ENTER_MEMORY" in category:
            _increment_debug_stat("memory_mode_activations")
    elif category.begins_with("PATHFINDING_") and zombie.debug_pathfinding_enabled:
        should_log = true
        formatted_message = "🗺️ " + formatted_message
        if "RECALC" in category or "PATH_CALCULATED" in category:
            _increment_debug_stat("pathfinding_recalculations")
    elif category.begins_with("AREA2D_") and zombie.debug_area2d_enabled:
        should_log = true
        formatted_message = "🎯 " + formatted_message
    
    if should_log:
        print(formatted_message)

func _find_zombie_by_id(zombie_id: String) -> Node:
    """Find zombie by ID for flag checking"""
    var zombies = get_tree().get_nodes_in_group("zombies")
    for zombie in zombies:
        if zombie.has_method("get") and "zombie_id" in zombie and zombie.zombie_id == zombie_id:
            return zombie
    return null

# ============================================================================
# ZOMBIE DEBUG PROFILE MANAGEMENT - Operates on zombie.gd flags
# ============================================================================

func toggle_zombie_debug_profiles():
    """Cycle through zombie debug profiles by updating zombie instances"""
    var zombies = get_tree().get_nodes_in_group("zombies")
    if zombies.is_empty():
        print("🔧 No zombies found to toggle debug flags")
        return
    
    # Get current state from first zombie (they should all be the same)
    var first_zombie = zombies[0]
    var current_profile = _get_current_debug_profile(first_zombie)
    
    # Cycle to next profile
    match current_profile:
        0: # All off -> Basic tracking
            _set_zombie_debug_profile(zombies, "basic")
            print("🔧 Zombie Debug Profile: BASIC (Movement + State)")
        1: # Basic -> Advanced
            _set_zombie_debug_profile(zombies, "advanced")
            print("🔧 Zombie Debug Profile: ADVANCED (Movement + State + LOS + Position)")
        2: # Advanced -> Memory focus
            _set_zombie_debug_profile(zombies, "memory")
            print("🔧 Zombie Debug Profile: MEMORY (Memory + Area2D)")
        3: # Memory -> All off
            _set_zombie_debug_profile(zombies, "off")
            print("🔧 Zombie Debug Profile: OFF (Quiet mode)")

func _get_current_debug_profile(zombie) -> int:
    """Determine current debug profile from zombie flags"""
    if not zombie.debug_movement_enabled and not zombie.debug_los_enabled:
        if zombie.debug_memory_system_enabled:
            return 3 # Memory profile
        else:
            return 0 # All off
    elif zombie.debug_movement_enabled and not zombie.debug_los_enabled:
        return 1 # Basic
    else:
        return 2 # Advanced

func _set_zombie_debug_profile(zombies: Array, profile: String):
    """Apply debug profile to all zombies - operates on zombie.gd flags"""
    for zombie in zombies:
        match profile:
            "off":
                zombie.debug_movement_enabled = false
                zombie.debug_los_enabled = false
                zombie.debug_state_transitions_enabled = false
                zombie.debug_position_updates_enabled = false
                zombie.debug_memory_system_enabled = false
                zombie.debug_area2d_enabled = false
                zombie.debug_pathfinding_enabled = false
            "basic":
                zombie.debug_movement_enabled = true
                zombie.debug_state_transitions_enabled = true
                zombie.debug_los_enabled = false
                zombie.debug_position_updates_enabled = false
                zombie.debug_memory_system_enabled = false
                zombie.debug_area2d_enabled = false
                zombie.debug_pathfinding_enabled = false
            "advanced":
                zombie.debug_movement_enabled = true
                zombie.debug_state_transitions_enabled = true
                zombie.debug_los_enabled = true
                zombie.debug_position_updates_enabled = true
                zombie.debug_memory_system_enabled = false
                zombie.debug_area2d_enabled = false
                zombie.debug_pathfinding_enabled = false
            "memory":
                zombie.debug_movement_enabled = false
                zombie.debug_los_enabled = false
                zombie.debug_state_transitions_enabled = false
                zombie.debug_position_updates_enabled = false
                zombie.debug_memory_system_enabled = true
                zombie.debug_area2d_enabled = true
                zombie.debug_pathfinding_enabled = false

# ============================================================================
# BUG-005 STATISTICS AND ANALYSIS
# ============================================================================

func _increment_debug_stat(stat_name: String):
    """Increment debug statistics for BUG-005 analysis"""
    if stat_name in zombie_debug_stats:
        zombie_debug_stats[stat_name] += 1

func _reset_per_second_stats():
    """Reset per-second statistics for accurate measurement"""
    zombie_debug_stats["los_checks_per_second"] = 0
    zombie_debug_stats["position_updates_per_second"] = 0
    zombie_debug_stats["state_transitions_per_second"] = 0

func print_zombie_debug_stats():
    """Print comprehensive BUG-005 debug statistics"""
    print("\n=== BUG-005 ZOMBIE DEBUG STATISTICS ===")
    print("Memory mode activations: ", zombie_debug_stats["memory_mode_activations"])
    print("LOS checks/sec: ", zombie_debug_stats["los_checks_per_second"])
    print("Position updates/sec: ", zombie_debug_stats["position_updates_per_second"])
    print("State transitions/sec: ", zombie_debug_stats["state_transitions_per_second"])
    print("Pathfinding recalcs: ", zombie_debug_stats["pathfinding_recalculations"])
    
    # Live zombie state analysis
    var zombies = get_tree().get_nodes_in_group("zombies")
    var memory_mode_count = 0
    var active_count = 0
    var chasing_count = 0
    var idle_count = 0
    
    for zombie in zombies:
        if zombie.has_method("get") and "is_in_memory_mode" in zombie:
            if zombie.is_in_memory_mode:
                memory_mode_count += 1
            else:
                active_count += 1
                if zombie.zombie_data:
                    match zombie.zombie_data.state:
                        zombie.zombie_data.ZombieState.CHASING:
                            chasing_count += 1
                        zombie.zombie_data.ZombieState.IDLE:
                            idle_count += 1
    
    print("Active zombies: ", active_count)
    print("Memory mode zombies: ", memory_mode_count)
    print("Chasing zombies: ", chasing_count)
    print("Idle zombies: ", idle_count)
    
    # Show current debug profile
    if zombies.size() > 0:
        var profile = _get_current_debug_profile(zombies[0])
        var profile_names = ["OFF", "BASIC", "ADVANCED", "MEMORY"]
        print("Current debug profile: ", profile_names[profile])
    
    print("=====================================\n")

func analyze_zombie_performance():
    """Analyze zombie performance for BUG-005 issues"""
    print("\n=== BUG-005 PERFORMANCE ANALYSIS ===")
    
    var zombies = get_tree().get_nodes_in_group("zombies")
    print("Total zombies: ", zombies.size())
    
    var problematic_zombies = []
    var memory_mode_zombies = []
    var high_update_zombies = []
    
    for zombie in zombies:
        if zombie.has_method("get_pathfinding_debug_info"):
            var debug_info = zombie.get_pathfinding_debug_info()
            
            # Check for potential issues
            if debug_info["path_size"] > 20:
                high_update_zombies.append(debug_info["zombie_id"])
            
        if zombie.has_method("get") and "is_in_memory_mode" in zombie:
            if zombie.is_in_memory_mode:
                memory_mode_zombies.append(zombie.zombie_id if "zombie_id" in zombie else "Unknown")
    
    if high_update_zombies.size() > 0:
        print("⚠️ Zombies with large paths (potential performance issue): ", high_update_zombies)
    
    if memory_mode_zombies.size() > 0:
        print("🧠 Zombies in memory mode: ", memory_mode_zombies)
    
    # Check for excessive debug stats
    if zombie_debug_stats["los_checks_per_second"] > 1000:
        print("⚠️ Excessive LOS checks detected: ", zombie_debug_stats["los_checks_per_second"])
    
    if zombie_debug_stats["position_updates_per_second"] > 500:
        print("⚠️ Excessive position updates detected: ", zombie_debug_stats["position_updates_per_second"])
    
    print("=====================================\n")

func reset_zombie_debug_stats():
    """Reset all BUG-005 debug statistics"""
    for key in zombie_debug_stats.keys():
        zombie_debug_stats[key] = 0
    print("🔧 Zombie debug statistics reset")

# ============================================================================
# ZOMBIE STATE DEBUG
# ============================================================================

func debug_all_zombie_states():
    """Enhanced zombie state debug with individual settings"""
    print("\n=== ZOMBIE STATE DEBUG ===")
    var zombies = get_tree().get_nodes_in_group("zombies")
    
    if zombies.is_empty():
        print("No zombies found in scene!")
        return
    
    print("Found ", zombies.size(), " zombies:")
    
    # Show current debug profile
    if zombies.size() > 0:
        var profile = _get_current_debug_profile(zombies[0])
        var profile_names = ["OFF", "BASIC", "ADVANCED", "MEMORY"]
        print("Current debug profile: ", profile_names[profile])
        print("Debug flags source: Individual zombie.gd @export variables")
    
    # Show detailed state for first 3 zombies (prevent spam)
    for i in range(min(zombies.size(), 3)):
        var zombie = zombies[i]
        print("\n--- Zombie ", i + 1, " (", zombie.zombie_id if "zombie_id" in zombie else "Unknown", ") ---")
        if zombie.has_method("debug_zombie_state"):
            zombie.debug_zombie_state()
        else:
            print("ERROR: Zombie missing debug_zombie_state() method")
    
    if zombies.size() > 3:
        print("\n... and ", zombies.size() - 3, " more zombies (use individual zombie.debug_zombie_state() for details)")
    
    # Show BUG-005 analysis
    analyze_zombie_performance()
    print("=== END ZOMBIE DEBUG ===\n")

# ============================================================================
# VISION SYSTEM DEBUG (PlayerSight integration)
# ============================================================================

func toggle_player_sight_range_debug():
    var player_sight = get_tree().get_first_node_in_group("player_sight")
    if player_sight:
        player_sight.debug_enabled = !player_sight.debug_enabled
        print("🔧 Player sight range debug: ", "ON" if player_sight.debug_enabled else "OFF")
    else:
        print("ERROR: PlayerSight not found!")

func toggle_zombie_sight_range_debug():
    var player_sight = get_tree().get_first_node_in_group("player_sight")
    if player_sight:
        player_sight.debug_zombie_sight_enabled = !player_sight.debug_zombie_sight_enabled
        if player_sight.has_method("_toggle_all_zombie_sight_debug"):
            player_sight._toggle_all_zombie_sight_debug()
        print("🔧 Zombie sight range debug: ", "ON" if player_sight.debug_zombie_sight_enabled else "OFF")
    else:
        print("ERROR: PlayerSight not found!")

func toggle_vision_state_logging():
    var player_sight = get_tree().get_first_node_in_group("player_sight")
    if player_sight:
        player_sight.debug_state_enabled = !player_sight.debug_state_enabled
        print("🔧 Vision state logging: ", "ON" if player_sight.debug_state_enabled else "OFF")
    else:
        print("ERROR: PlayerSight not found!")

func toggle_vision_signal_logging():
    var player_sight = get_tree().get_first_node_in_group("player_sight")
    if player_sight:
        player_sight.debug_sightrange_enabled = !player_sight.debug_sightrange_enabled
        print("🔧 Vision signal logging: ", "ON" if player_sight.debug_sightrange_enabled else "OFF")
    else:
        print("ERROR: PlayerSight not found!")

func toggle_vision_memory_logging():
    var player_sight = get_tree().get_first_node_in_group("player_sight")
    if player_sight:
        player_sight.debug_memory_enabled = !player_sight.debug_memory_enabled
        print("🔧 Vision memory logging: ", "ON" if player_sight.debug_memory_enabled else "OFF")
    else:
        print("ERROR: PlayerSight not found!")

func toggle_all_vision_logging():
    var player_sight = get_tree().get_first_node_in_group("player_sight")
    if player_sight:
        var new_state = !player_sight.debug_state_enabled
        player_sight.debug_state_enabled = new_state
        player_sight.debug_sightrange_enabled = new_state
        player_sight.debug_los_enabled = new_state
        player_sight.debug_memory_enabled = new_state
        player_sight.debug_verbose_enabled = new_state
        print("🔧 All vision logging: ", "ON" if new_state else "OFF")
    else:
        print("ERROR: PlayerSight not found!")

func reset_vision_debug_state():
    var player_sight = get_tree().get_first_node_in_group("player_sight")
    if player_sight and player_sight.has_method("reset_debug_state_tracking"):
        player_sight.reset_debug_state_tracking()
        print("🔧 Vision debug state tracking reset")
    else:
        print("ERROR: PlayerSight not found or missing reset method!")

# ============================================================================
# GLOBAL DEBUG TOGGLES
# ============================================================================

func toggle_memory_monitoring():
    memory_monitoring = not memory_monitoring
    var status = "ENABLED" if memory_monitoring else "DISABLED"
    print("🔧 Memory monitoring: ", status)

func toggle_collision_debug():
    collision_debug = not collision_debug
    var status = "ENABLED" if collision_debug else "DISABLED"
    print("🔧 Collision debug: ", status)

func toggle_ai_debug():
    ai_debug = not ai_debug
    var status = "ENABLED" if ai_debug else "DISABLED"
    print("🔧 AI debug: ", status)
    
    if ai_debug:
        print_ai_stats()

func toggle_physics_debug():
    physics_debug = not physics_debug
    var status = "ENABLED" if physics_debug else "DISABLED"
    print("🔧 Physics debug: ", status)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

func monitor_memory():
    """Monitor memory usage if memory monitoring is enabled"""
    if not memory_monitoring:
        return
        
    var memory_usage = OS.get_static_memory_usage()
    
    # Only print every 60 frames (once per second at 60 FPS)
    if Engine.get_process_frames() % 60 == 0:
        print("🔧 Memory: %.2f MB" % (memory_usage / 1024.0 / 1024.0))

func debug_print(category: String, message: String):
    """Centralized debug printing with category filtering"""
    match category:
        "memory":
            if memory_monitoring:
                print(message)
        "collision":
            if collision_debug:
                print(message)
        "ai":
            if ai_debug:
                print(message)
        "physics":
            if physics_debug:
                print(message)
        "combat":
            if ai_debug: # Combat debug uses ai_debug flag
                print(message)

# ============================================================================
# AI STATISTICS TRACKING
# ============================================================================

func register_zombie_death():
    """Called when zombie dies"""
    zombies_killed += 1
    debug_print("ai", get_detailed_zombie_info())

func register_bullet_fired():
    """Called when player fires a bullet"""
    increment_bullets_fired()

func register_bullet_hit():
    """Called when a bullet hits a target"""
    increment_bullets_hit()

func register_zombie_killed():
    """Called when a zombie is killed"""
    increment_zombies_killed()

func register_zombie_spawned():
    """Called when a zombie is spawned"""
    zombie_count += 1

func register_zombie_removed():
    """Called when a zombie is removed from scene"""
    zombie_count = max(0, zombie_count - 1)

func reset_ai_stats():
    """Reset all AI debug statistics"""
    zombie_count = 0
    zombies_killed = 0
    bullets_fired = 0
    bullets_hit = 0
    reset_zombie_debug_stats()
    print("🔧 AI stats reset")

func get_accuracy() -> float:
    """Get current shooting accuracy percentage"""
    if bullets_fired == 0:
        return 0.0
    return (float(bullets_hit) / float(bullets_fired)) * 100.0

func print_ai_stats():
    print("=== AI DEBUG STATS ===")
    print("Zombies Active: ", zombie_count)
    print("Zombies Killed: ", zombies_killed)
    print("Bullets Fired: ", bullets_fired)
    print("Bullets Hit: ", bullets_hit)
    if bullets_fired > 0:
        var accuracy = float(bullets_hit) / float(bullets_fired) * 100.0
        print("Accuracy: %.1f%%" % accuracy)
    print("======================")

func increment_bullets_fired():
    bullets_fired += 1

func increment_bullets_hit():
    bullets_hit += 1

func increment_zombies_killed():
    zombies_killed += 1

func update_zombie_count(count: int):
    zombie_count = count

func get_zombie_type_counts() -> Dictionary:
    var type_counts = {
        EntitiesType.ZombieType.WALKER: 0,
        EntitiesType.ZombieType.RUNNER: 0,
        EntitiesType.ZombieType.BRUTE: 0
    }
    
    var zombies = get_tree().get_nodes_in_group("zombies")
    for zombie in zombies:
        if zombie.zombie_data and zombie.zombie_data.zombie_type in type_counts:
            type_counts[zombie.zombie_data.zombie_type] += 1
    
    return type_counts

func get_active_zombie_count():
    return get_tree().get_nodes_in_group("zombies").size()

func get_detailed_zombie_info() -> String:
    var type_counts = get_zombie_type_counts()
    var total = get_active_zombie_count()
    
    var walker_count = type_counts[EntitiesType.ZombieType.WALKER]
    var runner_count = type_counts[EntitiesType.ZombieType.RUNNER]
    var brute_count = type_counts[EntitiesType.ZombieType.BRUTE]
    
    return "Active zombies: %d | W:%d R:%d B:%d | Killed: %d" % [
        total, walker_count, runner_count, brute_count, zombies_killed
    ]

# ============================================================================
# COMBAT DEBUG
# ============================================================================

func debug_print_combat_damage(target_node: Node, final_damage: int, damage_type: DamageInterface.DamageType, resistance_percent: float):
    """Log detailed combat damage events"""
    var target_name = "Unknown"
    
    # Check if target has zombie_data and zombie_type
    if target_node.has_method("get") and "zombie_data" in target_node and target_node.zombie_data:
        target_name = EntitiesType.get_zombie_type_name(target_node.zombie_data.zombie_type)
    elif target_node.is_in_group("player"):
        target_name = "Player"
    else:
        target_name = target_node.get_class()
    
    # Convert enum value to string name using find_key()
    var damage_type_string = DamageInterface.DamageType.find_key(damage_type)
    
    var message = "%s took %s %s damage (Resisted: %.1f%%)" % [
        target_name,
        final_damage,
        damage_type_string,
        resistance_percent
    ]
    debug_print("combat", message)

# ============================================================================
# GENERAL DEBUG LOGGING
# ============================================================================

func log_debug(message: String):
    """General debug logging function for system events"""
    if ai_debug:
        print("🔧 DEBUG: ", message)

func log_debug_categorized(category: String, message: String):
    """Debug logging with category support"""
    debug_print(category, "🔧 " + message)
