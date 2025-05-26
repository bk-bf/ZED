# _archieved_systems/unused_mechanics/zombie_data.gd
extends Resource
class_name ZombieData

@export var instance_id: int = -1
@export var position: Vector2 = Vector2.ZERO
@export var health: int = 100
@export var max_health: int = 100
@export var speed: float = 50.0
@export var damage: int = 10
@export var detection_range: float = 100.0
@export var attack_range: float = 32.0
@export var is_active: bool = true
@export var target_position: Vector2 = Vector2.ZERO
@export var state: ZombieState = ZombieState.IDLE

enum ZombieState {
    IDLE,
    PATROLLING,
    CHASING,
    ATTACKING,
    DEAD
}

func take_damage(amount: int):
    health = max(0, health - amount)
    if health <= 0:
        state = ZombieState.DEAD
        is_active = false

func is_alive() -> bool:
    return health > 0 and is_active
