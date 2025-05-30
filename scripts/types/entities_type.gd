# scripts/types/entities_type.gd
class_name EntitiesType

# Zombie type definitions for ZED project
# Used across AI systems, wave spawning, UI, and debug tracking
enum ZombieType {
	WALKER = 0, # Standard zombie - balanced stats
	RUNNER = 1, # Fast zombie - high speed, lower health
	BRUTE = 2 # Tank zombie - high health, slow speed
}

# Static methods for zombie type information
static func get_zombie_type_name(type: ZombieType) -> String:
	match type:
		ZombieType.WALKER:
			return "Walker"
		ZombieType.RUNNER:
			return "Runner"
		ZombieType.BRUTE:
			return "Brute"
		_:
			return "Unknown"

static func get_zombie_type_description(type: ZombieType) -> String:
	match type:
		ZombieType.WALKER:
			return "Standard zombie with balanced stats"
		ZombieType.RUNNER:
			return "Fast-moving zombie with reduced health"
		ZombieType.BRUTE:
			return "Heavily armored zombie with high health"
		_:
			return "Unknown zombie type"

# Get all available zombie types for iteration
static func get_all_zombie_types() -> Array[ZombieType]:
	return [ZombieType.WALKER, ZombieType.RUNNER, ZombieType.BRUTE]

# Random zombie type selection for wave spawning
static func get_random_zombie_type() -> ZombieType:
	var types = get_all_zombie_types()
	return types[randi() % types.size()]

# Weighted random selection for progressive difficulty
static func get_weighted_zombie_type(wave_number: int) -> ZombieType:
	# Early waves favor WALKER, later waves introduce variety
	var walker_weight = max(1, 5 - wave_number) # Decreases over time
	var runner_weight = min(3, wave_number) # Increases with waves
	var brute_weight = max(0, wave_number - 3) # Appears after wave 3
	
	var total_weight = walker_weight + runner_weight + brute_weight
	var random_value = randi() % total_weight
	
	if random_value < walker_weight:
		return ZombieType.WALKER
	elif random_value < walker_weight + runner_weight:
		return ZombieType.RUNNER
	else:
		return ZombieType.BRUTE
