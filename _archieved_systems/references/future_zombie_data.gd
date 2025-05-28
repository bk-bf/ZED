# scripts/entities/zombie_data.gd
extends Resource
class_name ZombieData

@export var instance_id: int = -1
@export var position: Vector2 = Vector2.ZERO
@export var health: int = 100
@export var max_health: int = 100
@export var speed: float = 50.0
@export var damage: int = 25
@export var detection_range: float = 100.0 # keep?
@export var attack_range: float = 32.0 # keep?
@export var is_active: bool = true # keep?
@export var target_position: Vector2 = Vector2.ZERO
@export var state: ZombieState = ZombieState.IDLE

# damage cooldown
var current_cooldown: float = 0.0
var damage_cooldown_duration: float = 1.0 # second

# loot pool dictionary
@export var loot_pool: Dictionary = {}

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
	loot_pool["placeholder_pistol_ammo"] = 1.0

func get_resistances() -> Dictionary:
	return {
		DamageInterface.DamageType.BULLET: 0.0, # 0% bullet resistance
		DamageInterface.DamageType.CONTACT: 0.0
	}

func take_damage(amount: int):
	health = max(0, health - amount)
	if health <= 0:
		state = ZombieState.DEAD
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
