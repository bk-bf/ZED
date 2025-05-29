# scripts/entities/zombie_data.gd
extends Resource
class_name ZombieData

@export var instance_id: int = -1
@export var position: Vector2 = Vector2.ZERO
@export var health: int = 100
@export var speed: float = 50.0
@export var max_health: int = 100
@export var damage: int = 25
@export var sight_range: float = 300.0
@export var target_position: Vector2 = Vector2.ZERO
@export var is_active: bool = true

# damage cooldown
var current_cooldown: float = 0.0
var damage_cooldown_duration: float = 1.0 # second

# loot pool dictionary
@export var loot_pool: Dictionary = {}

# Zombie states
@export var state: ZombieState = ZombieState.IDLE

enum ZombieState {
	IDLE,
	PATROLLING,
	CHASING,
	ATTACKING,
	DEAD
}

func _init():
	health = max_health
	
	# Set up default loot pool with 100% pistol ammo drop chance
	# Combined structure: item_id -> {chance: float, min_amount: int, max_amount: int}
	loot_pool["placeholder_pistol_ammo"] = {
		"chance": 1.0,
		"min_amount": 3,
		"max_amount": 8
	}


func get_resistances() -> Dictionary:
	return {
		DamageInterface.DamageType.BULLET: 0.0, # 0% bullet resistance
		DamageInterface.DamageType.CONTACT: 0.0
	}

func take_damage(amount: int):
	health = max(0, health - amount)
	if health <= 0:
		is_active = false

func is_alive() -> bool:
	return health > 0 and is_active

func can_damage() -> bool:
	return current_cooldown <= 0.0

func apply_damage_cooldown():
	current_cooldown = damage_cooldown_duration

func update_cooldown(delta: float):
	if current_cooldown > 0.0:
		current_cooldown = max(0.0, current_cooldown - delta)

func get_loot_drops() -> Array:
	var drops: Array = []
	
	for item_id in loot_pool.keys():
		var loot_data = loot_pool[item_id]
		
		# Check if this item should drop based on chance
		if randf() <= loot_data["chance"]:
			# Calculate random amount within range
			var drop_amount = randi_range(loot_data["min_amount"], loot_data["max_amount"])
			
			# Add to drops array
			drops.append({
				"item_id": item_id,
				"amount": drop_amount
			})
	
	return drops

func create_pickup_items() -> Array:
	var pickup_items = []
	var drops = get_loot_drops()
	
	for drop in drops:
		pickup_items.append({
			"item_id": drop["item_id"],
			"amount": drop["amount"],
			"position": position # Zombie's death position
		})
	
	return pickup_items
