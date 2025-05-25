extends Resource
class_name ProjectileData

@export var instance_id: int = -1
@export var position: Vector2 = Vector2.ZERO
@export var velocity: Vector2 = Vector2.ZERO
@export var damage: int = 25
@export var lifetime: float = 2.0
@export var is_active: bool = true
@export var owner_type: String = "player" # "player" or "enemy"

func update_position(delta: float):
    position += velocity * delta
    lifetime -= delta
    if lifetime <= 0:
        is_active = false
