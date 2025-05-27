# scripts/entities/armor_data.gd
extends Resource
class_name ArmorData

@export var name: String = "Basic Armor"
@export var resistances := {
    DamageInterface.DamageType.BULLET: 0.0,
    DamageInterface.DamageType.CONTACT: 0.0,
    DamageInterface.DamageType.ENVIRONMENTAL: 0.0
}

func get_resistances() -> Dictionary:
    return resistances
