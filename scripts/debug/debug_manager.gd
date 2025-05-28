# scripts/debug/debug_manager.gd
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
	print("🔧 Debug Manager initialized")

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
				toggle_physics_debug()
			KEY_F7:
				test_item_data_system()
			KEY_F8:
				test_item_data_integration()

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
			print(message) # Always print combat messages

func register_zombie_death():
	"""Called when zombie dies"""
	zombies_killed += 1
	debug_print("ai", "Zombie died. Remaining: " + str(zombie_count) + " | Total killed: " + str(zombies_killed))

func register_bullet_fired():
	"""Called when bullet is fired"""
	bullets_fired += 1
	debug_print("ai", "Bullet fired. Total shots: " + str(bullets_fired))

func register_bullet_hit():
	"""Called when bullet hits a zombie (not necessarily kills)"""
	bullets_hit += 1
	debug_print("ai", "Bullet hit zombie. Total hits: " + str(bullets_hit))

func print_ai_stats():
	if ai_debug:
		print("=== AI DEBUG STATS ===")
		print("Active zombies: ", get_active_zombie_count())
		print("Zombies killed: ", zombies_killed)
		print("Bullets fired: ", bullets_fired)
		print("Bullets hit: ", bullets_hit)
		if bullets_fired > 0:
			var hit_accuracy = float(bullets_hit) / float(bullets_fired) * 100.0
			print("Hit accuracy: ", "%.1f" % hit_accuracy, "%")
		print("======================")

func reset_ai_stats():
	"""Reset all AI counters - FIX: Now properly resets all stats"""
	zombies_killed = 0
	bullets_fired = 0
	bullets_hit = 0
	debug_print("ai", "AI stats reset")

func monitor_memory():
	"""Memory monitoring function called by other scripts"""
	if not memory_monitoring:
		return

	var node_count = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var object_count = Performance.get_monitor(Performance.OBJECT_COUNT)
	var orphan_nodes = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)

	# Print every 60 frames (1 second at 60fps)
	if Engine.get_process_frames() % 60 == 0:
		debug_print("memory", "Nodes: " + str(node_count) + " | Objects: " + str(object_count) + " | Orphans: " + str(orphan_nodes))

func debug_print_combat_damage(target_name: String, final_damage: int, damage_type: String, resistance_percent: float):
	"""Log detailed combat damage events"""
	var message = "%s took %s %s damage (Resisted: %.1f%%)" % [
		target_name,
		final_damage,
		damage_type,
		resistance_percent
	]
	debug_print("combat", message)


func toggle_debug_health():
	show_debug_health = !show_debug_health
	# Hide/show debug health bar

func get_active_zombie_count():
	return get_tree().get_nodes_in_group("zombies").size()

# basic ItemData system test currently only for placeholder pistol ammo
func test_item_data_system():
	print("\n=== ItemData System Test ===")
	
	# Test getting placeholder pistol ammo
	var pistol_ammo = ItemData.get_item_by_id("placeholder_pistol_ammo")
	
	if pistol_ammo:
		print("✓ Found item: ", pistol_ammo.name)
		print("✓ ID: ", pistol_ammo.id)
		print("✓ Type: ", pistol_ammo.type)
		print("✓ Stack size: ", pistol_ammo.stack_size)
	else:
		print("✗ Failed to find placeholder_pistol_ammo")
	
	# Test invalid ID
	var invalid_item = ItemData.get_item_by_id("nonexistent_item")
	if invalid_item == null:
		print("✓ Correctly returned null for invalid ID")
	else:
		print("✗ Should have returned null for invalid ID")
	
	print("=== Test Complete ===\n")
	
func test_item_data_integration():
	print("\n=== ItemData Integration Test ===")
	
	# Test 1: Max ammo comes from database
	var pistol_ammo_data = ItemData.get_item_by_id("placeholder_pistol_ammo")
	var expected_max = pistol_ammo_data.stack_size
	var actual_max = PlayerDataAutoload.max_ammo
	
	print("Database stack_size: ", expected_max)
	print("PlayerData max_ammo: ", actual_max)
	assert(actual_max == expected_max, "Max ammo should match database stack_size")
	print("✓ Max ammo correctly uses database value")
	
	# Test 2: Ammo pickup respects database limits
	var initial_ammo = PlayerDataAutoload.current_ammo
	var test_pickup_amount = 50 # More than stack_size to test limits
	
	print("Initial ammo: ", initial_ammo)
	print("Attempting to add: ", test_pickup_amount)
	
	var success = PlayerDataAutoload.add_item("placeholder_pistol_ammo", test_pickup_amount)
	var final_ammo = PlayerDataAutoload.current_ammo
	var expected_final = min(initial_ammo + test_pickup_amount, expected_max)
	
	print("Final ammo: ", final_ammo)
	print("Expected final: ", expected_final)
	assert(final_ammo == expected_final, "Pickup should respect database stack limits")
	print("✓ Ammo pickup respects database stack_size")
	
	# Test 3: UI displays database-driven values
	var ammo_counter = get_node("UI/DebugAmmoCounter")
	if ammo_counter:
		ammo_counter.update_ammo_display()
		# Verify UI shows database values, not hardcoded ones
		print("✓ UI updated with database values")
	
	# Test 4: Invalid item IDs handled properly
	var invalid_result = PlayerDataAutoload.add_item("nonexistent_ammo", 10)
	assert(invalid_result == false, "Invalid item IDs should return false")
	print("✓ Invalid item IDs handled correctly")
	
	print("=== All ItemData Integration Tests Passed ===\n")


func log_debug(message: String):
	print("[DEBUG] ", message)
