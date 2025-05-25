extends Resource
class_name LootData

@export var instance_id: int = -1
@export var position: Vector2 = Vector2.ZERO
@export var item_type: String = "ammo"
@export var item_name: String = "Pistol Ammo"
@export var quantity: int = 10
@export var is_collected: bool = false

enum LootType {
    WEAPON,
    AMMO,
    MEDICAL,
    BUILDING_MATERIAL,
    FOOD
}
