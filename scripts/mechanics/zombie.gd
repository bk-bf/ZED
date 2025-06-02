# In zombie.gd - FIXED: Removed all memory system interference
extends CharacterBody2D
class_name Zombie

@export var zombie_data: ZombieData
@export var armor: Resource = null # ArmorData resource
var is_dead: bool = false
var damage_area: Area2D # Store reference to damage area
var player_in_damage_area: bool = false # Track if player is in damage area
var debug_label: Label

# DEBUG FLAGS - BUG-005 Focused Debug System
@export_group("Debug Configuration")
@export var debug_enabled: bool = true
## Master debug toggle - controls system-level logging (init, setup, errors)
## Example: "🧟 [WALKER_123] SYSTEM_INIT: Zombie WALKER_123 initialization complete 
# - Type: WALKER, Speed: 100.0, Sight: 200.0"
# ✅ Always on
@export var debug_sight_enabled: bool = true
## Visual sight range circles drawn around zombies (red translucent circles)
## Shows: sight radius overlay, pathfinding waypoints if enabled
## Example: Red circle with 200px radius around zombie showing detection area
# ✅ Visual feedback
@export var debug_movement_enabled: bool = true # Start disabled to reduce spam
## Movement and velocity tracking - logs when zombies change movement direction/speed
## Example: "🏃 [WALKER_123] MOVEMENT_DIRECT_CHASE: Velocity: (45.2, -12.8), Speed: 100.0"
# ❌ Too spammy initially
@export var debug_los_enabled: bool = true # Start disabled to reduce spam
## Line of sight validation - logs LOS checks and what blocks zombie vision
## Example: "👁️ [WALKER_123] LOS_BLOCKED: LOS blocked by: LeftWall at distance 87.3"
# ❌ Too spammy initially
@export var debug_state_transitions_enabled: bool = true # Start disabled to reduce spam
## State change tracking - logs when zombies switch between IDLE/CHASING/DEAD states
## Example: "🔄 [WALKER_123] STATE_CHANGE: From IDLE to CHASING"
# ❌ Too spammy initially
@export var debug_position_updates_enabled: bool = true # Start disabled to reduce spam
## Position update spam monitoring - tracks target position changes (BUG-005 culprit)
## Example: "📍 [WALKER_123] POSITION_DIRECT_CHASE: New target: (456.7, 234.1) (Distance: 123.4)"
# ❌ MAJOR spam source
@export var debug_physics_enabled: bool = true # Start disabled - only needed for setup validation
## Physics validation - collision layers, wall detection, Area2D setup verification
## Example: "🧟 [WALKER_123] SYSTEM_PHYSICS_VALIDATION: ✓ Sight range configuration consistent"
 # ❌ Only for setup issues
@export var debug_area2d_enabled: bool = true # Start disabled to reduce spam
## Area2D signal tracking - logs when player enters/exits zombie sight Area2D
## Example: "🎯 [WALKER_123] AREA2D_ENTERED_SIGHT: Player entered Area2D for WALKER_123"
 # ❌ Moderate spam
@export var debug_pathfinding_enabled: bool = false
## A* pathfinding debug - shows path calculation, waypoint following, recalculation triggers
## Example: "🗺️ [WALKER_123] PATHFINDING_PATH_CALCULATED: Path to (789.1, 456.3) with 7 waypoints"
# ❌ Only if using A*

# Enhanced position tracking for accurate "last seen" positions
var last_seen_player_position: Vector2 = Vector2.ZERO
var player_exit_position: Vector2 = Vector2.ZERO
var is_tracking_player: bool = false

# REMOVED: All memory system variables - zombies should never be controlled by memory system
# var is_in_memory_mode: bool = false
# var memory_position: Vector2 = Vector2.ZERO

# Debouncing state change to prevent rapid state changes
var last_state_change_time: float = 0.0
var min_state_change_interval: float = 0.1 # 100ms minimum

# A* Pathfinding integration (toggleable)
var pathfinding_manager: PathfindingManager
var current_path: PackedVector2Array = PackedVector2Array()
var path_index: int = 0
var path_recalc_timer: float = 0.0
var path_recalc_interval: float = 0.5 # Recalculate path every 500ms
@export var use_pathfinding: bool = false # Toggle between A* and simple movement
var last_pathfinding_target: Vector2 = Vector2.ZERO

# Debug visualization and identification
var sight_range_node: Area2D
var zombie_id: String = "" # Unique identifier for clear debug output

func _ready():
	# Generate unique zombie ID immediately for clear debug logging
	_generate_zombie_id()
	
	# Log zombie initialization
	_debug_log_system("INIT", "Zombie %s initializing" % zombie_id)
	
	_initialize_zombie_data()
	_setup_collision_layers()
	_setup_zombie_sight_range()
	_setup_damage_area()
	add_to_group("zombies")
	_create_debug_label()

	DebugManager.register_zombie_spawned()
	_set_zombie_type_color()
	
	# FIXED: Start visible by default - PlayerSight will control visibility but not freeze zombie
	visible = true
	modulate = Color.WHITE
	
	_initialize_pathfinding()
	
	# Debug validation
	if debug_physics_enabled:
		_verify_physics_setup()
	
	# Optional comprehensive wall detection test
	if debug_physics_enabled:
		call_deferred("_debug_wall_detection")
	
	_debug_log_system("INIT", "Zombie %s initialization complete - Type: %s, Speed: %.1f, Sight: %.1f" % [
		zombie_id,
		_get_zombie_type_name(),
		zombie_data.speed if zombie_data else 0.0,
		zombie_data.sight_range if zombie_data else 0.0
	])

func _generate_zombie_id():
	"""Generate a unique, readable zombie ID"""
	var type_name = _get_zombie_type_name()
	var instance_id = get_instance_id()
	zombie_id = "%s_%d" % [type_name, instance_id % 1000] # Keep ID manageable
	self.name = zombie_id # Update node name for clearer hierarchy

func _create_debug_label():
	"""Create debug ID label above zombie"""
	if not debug_enabled:
		return
		
	debug_label = Label.new()
	debug_label.text = zombie_id
	debug_label.modulate = Color.YELLOW
	debug_label.position = Vector2(-20, -40) # Above zombie
	debug_label.add_theme_font_size_override("font_size", 12)
	add_child(debug_label)
	
	# Update label based on state
	_update_debug_label()

func _update_debug_label():
	"""Update debug label with current state and memory status"""
	if not debug_label:
		return
		
	var state_text = ""
	match zombie_data.state:
		ZombieData.ZombieState.IDLE:
			state_text = "IDLE"
			debug_label.modulate = Color.WHITE
		ZombieData.ZombieState.CHASING:
			state_text = "CHASE"
			debug_label.modulate = Color.RED
		ZombieData.ZombieState.DEAD:
			state_text = "DEAD"
			debug_label.modulate = Color.GRAY
	
	# Check if this zombie is in memory
	var player_sight = get_tree().get_first_node_in_group("player_sight")
	var in_memory = false
	if player_sight and player_sight.memory_data.has(zombie_id):
		in_memory = true
	
	var memory_text = " [MEM]" if in_memory else ""
	debug_label.text = "%s-%s%s" % [zombie_id, state_text, memory_text]

func _get_zombie_type_name() -> String:
	"""Get readable zombie type name"""
	if not zombie_data:
		return "UNKNOWN"
	
	match zombie_data.zombie_type:
		EntitiesType.ZombieType.WALKER:
			return "WALKER"
		EntitiesType.ZombieType.RUNNER:
			return "RUNNER"
		EntitiesType.ZombieType.BRUTE:
			return "BRUTE"
		_:
			return "UNKNOWN"

func _initialize_pathfinding():
	"""Initialize A* pathfinding system with debug logging"""
	pathfinding_manager = get_tree().get_first_node_in_group("pathfinding")
	if pathfinding_manager:
		_debug_log_pathfinding("INIT", "PathfindingManager connected successfully")
		if not use_pathfinding:
			_debug_log_pathfinding("INIT", "A* pathfinding DISABLED by configuration")
	else:
		_debug_log_pathfinding("ERROR", "No PathfindingManager found - using simple movement only")
		use_pathfinding = false

func _set_zombie_type_color():
	"""Set visual color based on zombie type"""
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
	"""Initialize zombie data with debug validation"""
	if not zombie_data:
		zombie_data = ZombieData.new()
		_debug_log_system("INIT", "Created new ZombieData - Health: %d/%d" % [zombie_data.health, zombie_data.max_health])

func _setup_zombie_sight_range():
	"""Setup zombie sight range with debug validation"""
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
	
	# Ensure Area2D radius matches zombie_data.sight_range
	var collision_shape = sight_range.get_node("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		var desired_radius = zombie_data.sight_range if zombie_data else 150.0
		collision_shape.shape.radius = desired_radius
		_debug_log_system("SETUP", "Sight range configured: %.1f" % desired_radius)
	
	_connect_sight_signals()

func _connect_sight_signals():
	"""Connect sight signals with improved debug logging"""
	var sight_range = get_node_or_null("SightRange")
	if sight_range:
		if not sight_range.body_entered.is_connected(_on_player_entered_zombie_sight):
			sight_range.body_entered.connect(_on_player_entered_zombie_sight)
		if not sight_range.body_exited.is_connected(_on_player_left_zombie_sight):
			sight_range.body_exited.connect(_on_player_left_zombie_sight)
		
		# FIXED: Clear zombie identification in debug output
		_debug_log_system("SETUP", "Sight signals connected for %s" % zombie_id)
	else:
		_debug_log_system("ERROR", "Could not connect sight signals - SightRange not found")

# REMOVED: All memory system methods - zombies should never be controlled by memory system
# func set_memory_mode(in_memory: bool, frozen_pos: Vector2 = Vector2.ZERO):
# func get_memory_state() -> bool:

func _physics_process(delta):
	if not zombie_data or is_dead:
		return
	
	# Store old state for change detection
	var old_state = zombie_data.state
	
	# FIXED: Always check for player, don't rely only on detected_player
	var player = get_tree().get_first_node_in_group("player")
	
	if player and is_instance_valid(player):
		# CRITICAL FIX: Always check both range AND LOS in physics process
		var is_in_range = _is_player_in_zombie_sight_range(player)
		var has_los = _has_line_of_sight_to_player(player)
		
		# Log sight validation for BUG-005 analysis
		_debug_log_los("VALIDATION", "Range: %s, LOS: %s" % [is_in_range, has_los])
		
		# FIXED: Proper state management - ONLY chase when CAN SEE player
		if is_in_range and has_los:
			# ONLY condition where zombie can START chasing - clear LOS
			last_seen_player_position = player.global_position # Update ONLY when visible
			is_tracking_player = true
			zombie_data.detected_player = player
			
			if zombie_data.state != ZombieData.ZombieState.CHASING:
				_change_state(ZombieData.ZombieState.CHASING)
				_log_state_change(old_state, zombie_data.state, "CLEAR_LOS")
				zombie_data.target_position = player.global_position
				_debug_log_position_update("CHASE_START", "Target: %s" % zombie_data.target_position)
			else:
				# Update target position ONLY when zombie can see player
				zombie_data.target_position = player.global_position
				last_seen_player_position = player.global_position # Update last seen
				_debug_log_position_update("CHASE_UPDATE", "Target: %s" % zombie_data.target_position)
				
		elif is_in_range and not has_los:
			# FIXED: Player behind wall - can't see them
			if zombie_data.state == ZombieData.ZombieState.CHASING:
				# Already chasing but lost LOS - continue to LAST KNOWN position
				if zombie_data.target_position != last_seen_player_position:
					zombie_data.target_position = last_seen_player_position # Use OLD position
					_debug_log_position_update("LOS_LOST", "Lost LOS, chasing to last seen: %s" % zombie_data.target_position)
				# DON'T update last_seen_player_position - we can't see the player!
			else:
				# FIXED: Not chasing and can't see player - stay idle
				_debug_log_state_transition("BLOCKED_STAY_IDLE", "Player behind wall, staying idle")
				zombie_data.detected_player = null
		
		elif not is_in_range:
			# Player completely out of Area2D range
			if zombie_data.state == ZombieData.ZombieState.CHASING:
				# Continue chasing to last known position
				if zombie_data.target_position == Vector2.ZERO:
					zombie_data.target_position = last_seen_player_position
					_debug_log_position_update("OUT_OF_RANGE", "Chasing to last seen: %s" % zombie_data.target_position)
				
				# Check if we've reached the last known position
				var distance_to_target = global_position.distance_to(zombie_data.target_position)
				if distance_to_target <= 32.0:
					# Reached last known position and player not in range - go idle
					_change_state(ZombieData.ZombieState.IDLE)
					_log_state_change(old_state, zombie_data.state, "REACHED_LAST_POSITION")
					zombie_data.target_position = Vector2.ZERO
					zombie_data.detected_player = null
					_debug_log_state_transition("OUT_OF_RANGE", "Reached last position, going idle")
			else:
				# Not chasing and not in range - ensure idle
				if zombie_data.state != ZombieData.ZombieState.IDLE:
					_change_state(ZombieData.ZombieState.IDLE)
					_log_state_change(old_state, zombie_data.state, "OUT_OF_RANGE")
					zombie_data.target_position = Vector2.ZERO
					zombie_data.detected_player = null
					_debug_log_state_transition("OUT_OF_RANGE", "Player out of range, going idle")
	else:
		# No player found in scene - ensure we're idle
		if zombie_data.state != ZombieData.ZombieState.IDLE:
			_change_state(ZombieData.ZombieState.IDLE)
			_log_state_change(old_state, zombie_data.state, "NO_PLAYER")
			zombie_data.target_position = Vector2.ZERO
			zombie_data.detected_player = null
			_debug_log_state_transition("NO_PLAYER", "No player in scene, going idle")
	
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
	
	# FIXED: Log state changes AFTER all processing
	if old_state != zombie_data.state:
		_debug_log_state_transition("STATE_CHANGE", "From %s to %s" % [
			ZombieData.ZombieState.find_key(old_state),
			ZombieData.ZombieState.find_key(zombie_data.state)
		])
		
		# Update debug label immediately
		_update_debug_label()
	
	move_and_slide()

# NEW: Dedicated state change logging function
func _log_state_change(old_state: ZombieData.ZombieState, new_state: ZombieData.ZombieState, reason: String):
	"""Log state changes with detailed reasoning"""
	_debug_log_state_transition("STATE_CHANGE", "From %s to %s (Reason: %s)" % [
		ZombieData.ZombieState.find_key(old_state),
		ZombieData.ZombieState.find_key(new_state),
		reason
	])

func chase_target(delta):
	"""Enhanced chase logic with proper state management"""
	var player = zombie_data.detected_player
	
	# BUG-005: Validate player and range/LOS
	if player and is_instance_valid(player):
		var is_in_range = _is_player_in_zombie_sight_range(player)
		var has_los = _has_line_of_sight_to_player(player)
		
		# Priority 1: Direct chase ONLY if both in range AND visible
		if is_in_range and has_los:
			path_recalc_timer += delta
			var target_pos = player.global_position
			
			# Update target position
			if zombie_data.target_position.distance_to(target_pos) > 32.0:
				zombie_data.target_position = target_pos
				_debug_log_position_update("DIRECT_CHASE", "New target: %s (Distance: %.1f)" % [
					zombie_data.target_position,
					global_position.distance_to(target_pos)
				])
			
			# Execute direct chase
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * zombie_data.speed
			
			_debug_log_movement("DIRECT_CHASE", "Velocity: %s, Speed: %.1f" % [velocity, zombie_data.speed])
			return
	
	# Priority 2: Move to stored target position (exit/last known)
	if zombie_data.target_position != Vector2.ZERO:
		var distance_to_target = global_position.distance_to(zombie_data.target_position)
		
		if distance_to_target > 16.0:
			# Move toward target
			if use_pathfinding and pathfinding_manager and _should_recalculate_path(zombie_data.target_position):
				_calculate_new_path(zombie_data.target_position)
			
			if use_pathfinding and current_path.size() > 0:
				_follow_astar_path(delta, false, false, null)
			else:
				var target_direction = (zombie_data.target_position - global_position).normalized()
				var movement_direction = _get_avoidance_direction(target_direction)
				velocity = movement_direction * zombie_data.speed * 0.8
				
				_debug_log_movement("SIMPLE_MOVE", "To target: %s, Distance: %.1f" % [
					zombie_data.target_position, distance_to_target
				])
		else:
			# Reached target - go idle (but don't force state change here, let physics_process handle it)
			_debug_log_state_transition("REACHED_TARGET", "Reached target at: %s" % global_position)
			zombie_data.target_position = Vector2.ZERO
			zombie_data.detected_player = null
			velocity = Vector2.ZERO
			current_path.clear()
			# Note: State change to IDLE will happen in next _physics_process cycle
	else:
		# No valid target - stop moving (but don't force state change here)
		_debug_log_movement("NO_TARGET", "No target available, stopping movement")
		velocity = Vector2.ZERO
		zombie_data.detected_player = null
		current_path.clear()
		# Note: State change to IDLE will happen in next _physics_process cycle

# BUG-005 FOCUSED: Enhanced Signal Handlers
func _on_player_entered_zombie_sight(body):
	"""Enhanced player detection with BUG-005 focused logging"""
	if body.is_in_group("player"):
		_debug_log_area2d("ENTERED_SIGHT", "Player entered Area2D for %s" % zombie_id)
		
		# Validate that player is actually visible (not just in Area2D)
		if _has_line_of_sight_to_player(body):
			zombie_data.detected_player = body
			last_seen_player_position = body.global_position
			is_tracking_player = true
			
			_debug_log_los("VALIDATED_DETECTION", "Player visible at: %s" % body.global_position)
		else:
			_debug_log_los("BLOCKED_DETECTION", "Player in Area2D but no LOS - wall blocking")

func _on_player_left_zombie_sight(body):
	"""Enhanced player exit handling with BUG-005 exit position tracking"""
	if body.is_in_group("player") and zombie_data.detected_player == body:
		_debug_log_area2d("LEFT_SIGHT", "Player left Area2D for %s" % zombie_id)
		
		# Calculate precise exit position at sight range boundary
		var new_exit_position = _get_exit_position_at_boundary(
			last_seen_player_position,
			global_position,
			zombie_data.sight_range
		)
		
		# BUG-005: Track exit position updates and rejection
		var position_change = player_exit_position.distance_to(new_exit_position)
		if position_change > 32.0:
			player_exit_position = new_exit_position
			zombie_data.target_position = player_exit_position
			
			_debug_log_position_update("EXIT_POSITION", "New exit target: %s (Change: %.1f)" % [
				player_exit_position, position_change
			])
			
			# Clear current path so it recalculates to new exit position
			current_path.clear()
			path_recalc_timer = path_recalc_interval
		else:
			_debug_log_position_update("EXIT_REJECTED", "Position change too small: %.1f < 32.0" % position_change)
		
		is_tracking_player = false

# BUG-005 FOCUSED: Enhanced Line of Sight with Debug Logging
func _has_line_of_sight_to_player(player) -> bool:
	"""FIXED: Match PlayerSight LOS detection exactly"""
	if not player or not is_instance_valid(player):
		return false
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)
	
	# FIXED: Match PlayerSight parameters exactly
	query.collision_mask = PhysicsLayers.WALLS
	query.exclude = [player] # FIXED: Only exclude player, not self
	# REMOVED: query.hit_from_inside = false
	
	var result = space_state.intersect_ray(query)
	var has_los = result.is_empty()
	var distance = global_position.distance_to(player.global_position)
	
	# Debug logging remains the same...
	if not has_los:
		_debug_log_los("BLOCKED", "LOS blocked by: %s at distance %.1f" % [
			result.collider.name if result.collider else "UNKNOWN",
			distance
		])
	else:
		_debug_log_los("CLEAR", "Clear LOS to player at distance %.1f" % distance)
	
	return has_los

# DEBUG LOGGING SYSTEM - BUG-005 Focused
func _debug_compare_los_systems(player) -> void:
	"""Compare zombie LOS vs PlayerSight LOS for debugging"""
	var space_state = get_world_2d().direct_space_state
	
	# Zombie's current method
	var zombie_query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	zombie_query.collision_mask = PhysicsLayers.WALLS
	zombie_query.exclude = [self, player]
	zombie_query.hit_from_inside = false
	var zombie_result = space_state.intersect_ray(zombie_query)
	
	# PlayerSight method from zombie perspective
	var player_style_query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	player_style_query.collision_mask = PhysicsLayers.WALLS
	player_style_query.exclude = [player] # Only exclude player
	var player_style_result = space_state.intersect_ray(player_style_query)
	
	# Compare results
	var zombie_has_los = zombie_result.is_empty()
	var player_style_has_los = player_style_result.is_empty()
	
	if zombie_has_los != player_style_has_los:
		_debug_log_los("COMPARISON", "LOS MISMATCH - Zombie: %s, PlayerStyle: %s" % [zombie_has_los, player_style_has_los])
		
		if not zombie_result.is_empty():
			_debug_log_los("COMPARISON", "Zombie blocked by: %s at %s" % [zombie_result.collider.name, zombie_result.position])
		
		if not player_style_result.is_empty():
			_debug_log_los("COMPARISON", "PlayerStyle blocked by: %s at %s" % [player_style_result.collider.name, player_style_result.position])
	else:
		_debug_log_los("COMPARISON", "LOS results match: %s" % zombie_has_los)
		
func _debug_log_system(category: String, message: String):
	"""System-level debug logging (initialization, setup, errors)"""
	if debug_enabled:
		DebugManager.log_zombie_debug(zombie_id, "SYSTEM_%s" % category, message)

func _debug_log_movement(category: String, message: String):
	"""Movement debug logging - addresses BUG-005 movement tracking"""
	if debug_movement_enabled:
		DebugManager.log_zombie_debug(zombie_id, "MOVEMENT_%s" % category, message)

func _debug_log_los(category: String, message: String):
	"""Line of sight debug logging - addresses BUG-005 LOS validation"""
	if debug_los_enabled:
		DebugManager.log_zombie_debug(zombie_id, "LOS_%s" % category, message)

func _debug_log_state_transition(category: String, message: String):
	"""State transition debug logging - addresses BUG-005 state changes"""
	if debug_state_transitions_enabled:
		DebugManager.log_zombie_debug(zombie_id, "STATE_%s" % category, message)

func _debug_log_position_update(category: String, message: String):
	"""Position update debug logging - addresses BUG-005 spam issue"""
	if debug_position_updates_enabled:
		DebugManager.log_zombie_debug(zombie_id, "POSITION_%s" % category, message)

func _debug_log_pathfinding(category: String, message: String):
	"""A* pathfinding debug logging"""
	if debug_pathfinding_enabled:
		DebugManager.log_zombie_debug(zombie_id, "PATHFINDING_%s" % category, message)

func _debug_log_area2d(category: String, message: String):
	"""Area2D signal debug logging - addresses BUG-005 signal analysis"""
	if debug_area2d_enabled:
		DebugManager.log_zombie_debug(zombie_id, "AREA2D_%s" % category, message)

# EXISTING METHODS - Updated with debug logging where relevant

func _is_player_in_zombie_sight_range(player) -> bool:
	"""Simplified range check with debug logging"""
	if not player:
		return false
		
	var sight_range = get_node_or_null("SightRange")
	if not sight_range:
		return false
	
	var in_area = sight_range.overlaps_body(player)
	
	# BUG-005: Log range validation results
	if debug_area2d_enabled:
		var distance = global_position.distance_to(player.global_position)
		_debug_log_area2d("RANGE_CHECK", "In area: %s, Distance: %.1f" % [in_area, distance])
	
	return in_area

# Rest of the file remains the same - pathfinding, utility methods, damage system, etc.
# [Previous methods preserved as they don't interfere with memory system]

func _should_recalculate_path(target_pos: Vector2) -> bool:
	"""Pathfinding recalculation logic with debug logging"""
	var should_recalc = false
	var reason = ""
	
	if path_recalc_timer >= path_recalc_interval:
		should_recalc = true
		reason = "Timer expired (%.2f >= %.2f)" % [path_recalc_timer, path_recalc_interval]
	elif current_path.size() == 0:
		should_recalc = true
		reason = "No current path"
	elif last_pathfinding_target.distance_to(target_pos) > 64.0:
		should_recalc = true
		reason = "Target moved %.1f units" % last_pathfinding_target.distance_to(target_pos)
	elif path_index >= current_path.size():
		should_recalc = true
		reason = "Path completed"
	
	if should_recalc:
		_debug_log_pathfinding("RECALC_TRIGGER", reason)
	
	return should_recalc

func _calculate_new_path(target_pos: Vector2):
	"""A* path calculation with debug logging"""
	if not use_pathfinding or not pathfinding_manager:
		return
		
	current_path = pathfinding_manager.find_path(global_position, target_pos)
	path_index = 0
	path_recalc_timer = 0.0
	last_pathfinding_target = target_pos
	zombie_data.target_position = target_pos
	
	if current_path.size() > 0:
		_debug_log_pathfinding("PATH_CALCULATED", "Path to %s with %d waypoints" % [
			target_pos, current_path.size()
		])
	else:
		_debug_log_pathfinding("PATH_FAILED", "Could not find path to %s" % target_pos)

func _follow_astar_path(delta: float, has_los: bool, is_in_range: bool, player: Node2D):
	"""A* path following with debug logging"""
	if path_index >= current_path.size():
		current_path.clear()
		velocity = Vector2.ZERO
		_debug_log_pathfinding("PATH_COMPLETE", "Reached end of path")
		return
	
	var target_waypoint = current_path[path_index]
	var distance_to_waypoint = global_position.distance_to(target_waypoint)
	
	# Check if we should switch to direct pursuit
	if has_los and is_in_range and distance_to_waypoint > 100.0:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * zombie_data.speed
		
		if zombie_data.target_position.distance_to(player.global_position) > 32.0:
			zombie_data.target_position = player.global_position
		
		_debug_log_pathfinding("DIRECT_OVERRIDE", "Switching to direct chase, player visible")
		return
	
	# Follow A* path
	if distance_to_waypoint < 20.0:
		path_index += 1
		_debug_log_pathfinding("WAYPOINT_REACHED", "Advanced to waypoint %d/%d" % [
			path_index + 1, current_path.size()
		])
		
		if path_index >= current_path.size():
			current_path.clear()
			velocity = Vector2.ZERO
		return
	
	# Move toward current waypoint
	var direction = (target_waypoint - global_position).normalized()
	velocity = direction * zombie_data.speed
	
	_debug_log_pathfinding("FOLLOWING", "Waypoint %d/%d, distance: %.1f" % [
		path_index + 1, current_path.size(), distance_to_waypoint
	])

# VISUAL DEBUG SYSTEM
func _draw():
	"""Enhanced debug visualization"""
	if debug_sight_enabled and visible and sight_range_node:
		var sight_radius = _get_zombie_sight_radius()
		if sight_radius > 0:
			# Draw sight range circle
			draw_circle(Vector2.ZERO, sight_radius, Color(1, 0, 0, 0.025))
			draw_arc(Vector2.ZERO, sight_radius, 0, TAU, 64, Color(1, 0, 0, 0.15), 1.5)
		
		# Draw A* path if using pathfinding
		if use_pathfinding and current_path.size() > 0 and debug_pathfinding_enabled:
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

# UTILITY METHODS - Preserved with minimal changes

func _get_zombie_sight_radius() -> float:
	"""Get the zombie's sight range radius"""
	if zombie_data:
		return zombie_data.sight_range
	return 150.0

func _get_exit_position_at_boundary(player_pos: Vector2, zombie_pos: Vector2, sight_radius: float) -> Vector2:
	"""Calculate precise position where player crossed the sight range boundary"""
	var direction = (player_pos - zombie_pos).normalized()
	return zombie_pos + (direction * sight_radius)

func _setup_collision_layers():
	collision_layer = PhysicsLayers.ENEMIES
	collision_mask = PhysicsLayers.PLAYER | PhysicsLayers.WALLS

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

func _connect_damage_signals():
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_area.body_exited.connect(_on_damage_area_body_exited)

func _get_avoidance_direction(target_direction: Vector2) -> Vector2:
	"""Simple wall avoidance for fallback movement"""
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

# All other methods remain the same...
# [Damage system, lifecycle methods, debug methods, etc. preserved]

func _process(delta):
	if is_dead:
		return
		
	zombie_data.update_cooldown(delta)
	
	if player_in_damage_area && zombie_data.can_damage():
		var overlapping = damage_area.get_overlapping_bodies()
		for body in overlapping:
			if body is PlayerController:
				DamageInterface.apply_damage(self, body, zombie_data.damage, DamageInterface.DamageType.CONTACT)
				zombie_data.apply_damage_cooldown()
				break

func _on_damage_area_body_entered(body):
	if body is PlayerController:
		player_in_damage_area = true
		if zombie_data.can_damage():
			DamageInterface.apply_damage(self, body, zombie_data.damage, DamageInterface.DamageType.CONTACT)
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
	
	_debug_log_system("DEATH", "Zombie died at position: %s" % global_position)
	
	DebugManager.register_zombie_death()
	
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	
	var loot_drops = zombie_data.get_loot_drops()
	for drop in loot_drops:
		_debug_log_system("LOOT", "Dropped %d of %s" % [drop["amount"], drop["item_id"]])

	call_deferred("_create_pickups")
	
	await get_tree().create_timer(0.5).timeout
	
	DebugManager.register_zombie_removed()
	queue_free()

func _create_pickups():
	zombie_data.position = global_position
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
	return zombie_data.health / float(zombie_data.max_health)

func get_direction_to_player() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		_debug_log_system("ERROR", "No player found in scene")
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

func _can_change_state() -> bool:
	var current_time = Time.get_ticks_msec() / 1000.0
	return current_time - last_state_change_time >= min_state_change_interval

func _change_state(new_state: ZombieData.ZombieState):
	if _can_change_state():
		zombie_data.state = new_state
		last_state_change_time = Time.get_ticks_msec() / 1000.0
		return true
	return false

func toggle_debug_sight():
	debug_sight_enabled = !debug_sight_enabled
	queue_redraw()
	_debug_log_system("DEBUG_TOGGLE", "Sight debug: %s" % ("ON" if debug_sight_enabled else "OFF"))

func set_debug_sight(enabled: bool):
	debug_sight_enabled = enabled
	queue_redraw()

# Validation and debug methods preserved...
func _verify_physics_setup():
	"""Comprehensive physics validation with debug output"""
	_debug_log_system("PHYSICS_VALIDATION", "Starting physics setup verification")
	
	var validation_results = []
	
	# Check collision layers
	validation_results.append("Collision layer: %d" % collision_layer)
	validation_results.append("Collision mask: %d" % collision_mask)
	
	# Check sight range setup
	var sight_range = get_node_or_null("SightRange")
	if sight_range:
		validation_results.append("SightRange collision_layer: %d" % sight_range.collision_layer)
		validation_results.append("SightRange collision_mask: %d" % sight_range.collision_mask)
		
		var configured_range = _get_zombie_sight_radius()
		var actual_area_radius = _get_area2d_actual_radius()
		validation_results.append("Configured sight_range: %.1f" % configured_range)
		validation_results.append("Actual Area2D radius: %.1f" % actual_area_radius)
		
		if abs(configured_range - actual_area_radius) > 1.0:
			validation_results.append("WARNING: Sight range mismatch detected!")
		else:
			validation_results.append("✓ Sight range configuration consistent")
	
	# Check wall detection
	var walls = get_tree().get_nodes_in_group("walls")
	validation_results.append("Found %d wall nodes in scene" % walls.size())
	
	if walls.size() > 0:
		var wall = walls[0]
		validation_results.append("First wall collision_layer: %d" % wall.collision_layer)
		validation_results.append("Expected wall layer (PhysicsLayers.WALLS = %d): %s" % [
			PhysicsLayers.WALLS,
			(wall.collision_layer & PhysicsLayers.WALLS) != 0
		])
	
	for result in validation_results:
		_debug_log_system("PHYSICS_VALIDATION", result)

func _debug_wall_detection():
	"""Comprehensive wall detection test"""
	var directions = [
		Vector2.RIGHT * 100, Vector2.LEFT * 100, Vector2.UP * 100, Vector2.DOWN * 100,
		Vector2(1, 1).normalized() * 100, Vector2(-1, 1).normalized() * 100,
		Vector2(1, -1).normalized() * 100, Vector2(-1, -1).normalized() * 100
	]
	
	var direction_names = [
		"RIGHT", "LEFT", "UP", "DOWN",
		"NORTHEAST", "NORTHWEST", "SOUTHEAST", "SOUTHWEST"
	]
	
	_debug_log_system("WALL_DETECTION", "Starting 8-direction wall detection test")
	
	for i in range(directions.size()):
		var dir_name = direction_names[i]
		var target_pos = global_position + directions[i]
		
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, target_pos)
		query.collision_mask = PhysicsLayers.WALLS
		query.exclude = [self]
		
		var result = space_state.intersect_ray(query)
		
		if result.is_empty():
			_debug_log_system("WALL_DETECTION", "%s: CLEAR" % dir_name)
		else:
			var distance = global_position.distance_to(result.position)
			_debug_log_system("WALL_DETECTION", "%s: BLOCKED by %s at distance %.1f" % [
				dir_name, result.collider.name, distance
			])

func _get_area2d_actual_radius() -> float:
	"""Get the actual radius being used by the Area2D"""
	var sight_range = get_node_or_null("SightRange")
	if not sight_range:
		return 0.0
	
	var collision_shape = sight_range.get_node_or_null("CollisionShape2D")
	if not collision_shape:
		return 0.0
	
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		return shape.radius
	
	return 0.0

func debug_zombie_state():
	"""Comprehensive zombie state debug output"""
	var debug_info = [
		"=== Zombie State Debug: %s ===" % zombie_id,
		"Type: %s" % _get_zombie_type_name(),
		"State: %s" % ZombieData.ZombieState.find_key(zombie_data.state),
		"Detected Player: %s" % zombie_data.detected_player,
		"Target Position: %s" % zombie_data.target_position,
		"Current Position: %s" % global_position,
		"Velocity: %s" % velocity,
		"Speed: %.1f" % zombie_data.speed,
		"Sight Range: %.1f" % zombie_data.sight_range,
		"Last Seen Player Position: %s" % last_seen_player_position,
		"Player Exit Position: %s" % player_exit_position,
		"Is Tracking Player: %s" % is_tracking_player,
		"Using Pathfinding: %s" % use_pathfinding,
		"Current Path Size: %d" % current_path.size(),
		"Path Index: %d" % path_index,
		"Path Recalc Timer: %.2f" % path_recalc_timer
	]
	
	if zombie_data.detected_player:
		var distance = global_position.distance_to(zombie_data.detected_player.global_position)
		var in_range = _is_player_in_zombie_sight_range(zombie_data.detected_player)
		var has_los = _has_line_of_sight_to_player(zombie_data.detected_player)
		debug_info.append("Player Distance: %.1f" % distance)
		debug_info.append("Player In Range: %s" % in_range)
		debug_info.append("Has Line of Sight: %s" % has_los)
	
	debug_info.append("========================")
	
	for info in debug_info:
		_debug_log_system("STATE_DEBUG", info)

# Pathfinding control methods
func force_recalculate_path():
	"""Force immediate path recalculation - useful for debug"""
	path_recalc_timer = path_recalc_interval
	current_path.clear()
	_debug_log_pathfinding("FORCED_RECALC", "Path recalculation forced")

func get_pathfinding_debug_info() -> Dictionary:
	"""Get pathfinding debug information"""
	return {
		"zombie_id": zombie_id,
		"using_pathfinding": use_pathfinding,
		"path_size": current_path.size(),
		"path_index": path_index,
		"recalc_timer": path_recalc_timer,
		"last_target": last_pathfinding_target
	}
