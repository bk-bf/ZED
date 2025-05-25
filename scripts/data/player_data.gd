extends Resource
class_name PlayerData

@export var instance_id: int = 0
@export var position: Vector2 = Vector2.ZERO
@export var health: int = 100
@export var max_health: int = 100
@export var speed: float = 200.0
@export var current_weapon: String = "pistol"
@export var ammo_count: int = 30
@export var inventory: Array[String] = []

func can_shoot() -> bool:
    return ammo_count > 0

func use_ammo():
    ammo_count = max(0, ammo_count - 1)
