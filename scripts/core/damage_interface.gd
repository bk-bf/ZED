# scripts/core/damage_interface.gd
extends RefCounted
class_name DamageInterface

enum DamageType {
    BULLET,
    CONTACT,
    ENVIRONMENTAL
}

static func apply_damage(source, target, base_damage: int, damage_type: DamageType) -> int:
    """Calculate and apply damage with resistances"""
    var resistances = target.get_resistances() if target.has_method("get_resistances") else {}
    var resistance = resistances.get(damage_type, 0.0)
    var final_damage = int(base_damage * (1.0 - resistance))
    
    if target.has_method("take_damage"):
        target.take_damage(final_damage, damage_type)
    
    # Get damage type name from enum
    var damage_type_name = DamageType.keys()[damage_type]

     # Log combat damage
    DebugManager.debug_print_combat_damage(
        target.name,
        final_damage,
        damage_type_name,
        resistance * 100
    )
    
    return final_damage
