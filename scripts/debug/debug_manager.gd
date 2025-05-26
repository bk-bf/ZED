# scripts/debug/debug_manager.gd
extends Node

# Debug toggles
var memory_monitoring: bool = false
var collision_debug: bool = false
var ai_debug: bool = false
var physics_debug: bool = false

# AI Debug counters
var zombie_count: int = 0
var zombies_killed: int = 0
var bullets_fired: int = 0
var bullets_hit: int = 0

func _ready():
	print("🔧 Debug Manager initialized - Press F3 for memory monitoring")

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


# AI Debug tracking functions
func register_zombie():
	"""Called when zombie spawns"""
	zombie_count += 1
	debug_print("ai", "Zombie spawned. Total zombies: " + str(zombie_count))

func register_zombie_death():
	"""Called when zombie dies"""
	zombie_count -= 1
	zombies_killed += 1
	debug_print("ai", "Zombie died. Remaining: " + str(zombie_count) + " | Total killed: " + str(zombies_killed))

func register_bullet_fired():
	"""Called when bullet is fired"""
	bullets_fired += 1
	debug_print("ai", "Bullet fired. Total shots: " + str(bullets_fired))

func print_ai_stats():
	"""Print current AI debug statistics"""
	if ai_debug:
		print("=== AI DEBUG STATS ===")
		print("Active zombies: ", zombie_count)
		print("Zombies killed: ", zombies_killed)
		print("Bullets fired: ", bullets_fired)
		print("Bullets hit: ", bullets_hit)

		if bullets_fired > 0:
			var hit_accuracy = float(bullets_hit) / float(bullets_fired) * 100.0
			print("Hit accuracy: ", "%.1f" % hit_accuracy, "%")

		print("======================")


func reset_ai_stats():
	"""Reset all AI counters"""
	zombie_count = 0
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
