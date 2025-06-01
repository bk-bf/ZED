# scripts/debug/debug_manager.gd
# Debug key bindings:
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

# Debug toggles
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

func _ready():
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
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
		player_sight._toggle_all_zombie_sight_debug()
		print("🔧 Zombie sight range debug: ", "ON" if player_sight.debug_zombie_sight_enabled else "OFF")
	else:
		print("ERROR: PlayerSight not found!")

func debug_all_zombie_states():
	print("\n=== ZOMBIE STATE DEBUG ===")
	var zombies = get_tree().get_nodes_in_group("zombies")
	
	if zombies.is_empty():
		print("No zombies found in scene!")
		return
	
	print("Found ", zombies.size(), " zombies:")
	
	for i in range(zombies.size()):
		var zombie = zombies[i]
		print("\n--- Zombie ", i + 1, " ---")
		if zombie.has_method("debug_zombie_state"):
			zombie.debug_zombie_state()
		else:
			print("ERROR: Zombie missing debug_zombie_state() method")
	
	print("=== END ZOMBIE DEBUG ===\n")

func toggle_vision_state_logging():
	var player_sight = get_tree().get_first_node_in_group("player_sight")
	if player_sight:
		player_sight.debug_state_logging = !player_sight.debug_state_logging
		print("🔧 Vision state logging: ", "ON" if player_sight.debug_state_logging else "OFF")
	else:
		print("ERROR: PlayerSight not found!")

func toggle_vision_signal_logging():
	var player_sight = get_tree().get_first_node_in_group("player_sight")
	if player_sight:
		player_sight.debug_signal_logging = !player_sight.debug_signal_logging
		print("🔧 Vision signal logging: ", "ON" if player_sight.debug_signal_logging else "OFF")
	else:
		print("ERROR: PlayerSight not found!")

func toggle_vision_memory_logging():
	var player_sight = get_tree().get_first_node_in_group("player_sight")
	if player_sight:
		player_sight.debug_memory_logging = !player_sight.debug_memory_logging
		print("🔧 Vision memory logging: ", "ON" if player_sight.debug_memory_logging else "OFF")
	else:
		print("ERROR: PlayerSight not found!")

func toggle_all_vision_logging():
	var player_sight = get_tree().get_first_node_in_group("player_sight")
	if player_sight:
		var new_state = !player_sight.debug_state_logging
		player_sight.debug_state_logging = new_state
		player_sight.debug_signal_logging = new_state
		player_sight.debug_raycast_logging = new_state
		player_sight.debug_memory_logging = new_state
		player_sight.debug_verbose_logging = new_state
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

func monitor_memory():
	"""Monitor memory usage if memory monitoring is enabled"""
	if not memory_monitoring:
		return
		
	var memory_usage = OS.get_static_memory_usage()
	
	# Only print every 60 frames (once per second at 60 FPS)
	if Engine.get_process_frames() % 60 == 0:
		print("🔧 Memory: %.2f MB" % (memory_usage / 1024.0 / 1024.0))

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
	print("🔧 AI stats reset")

func get_accuracy() -> float:
	"""Get current shooting accuracy percentage"""
	if bullets_fired == 0:
		return 0.0
	return (float(bullets_hit) / float(bullets_fired)) * 100.0

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

# Called by other systems to update debug counters
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


func log_debug(message: String):
	"""General debug logging function for system events"""
	if ai_debug: # Use ai_debug flag to control general debug logging
		print("🔧 DEBUG: ", message)

# Alternative: More specific logging with categories
func log_debug_categorized(category: String, message: String):
	"""Debug logging with category support"""
	debug_print(category, "🔧 " + message)
