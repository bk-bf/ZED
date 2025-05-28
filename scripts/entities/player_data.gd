# PlayerData.gd (Autoload)
extends Node
class_name PlayerData

@export var instance_id: int = 0
@export var position: Vector2 = Vector2.ZERO
@export var health: int = 100
@export var max_health: int = 100
@export var speed: float = 200.0
@export var current_weapon: String = "pistol"
@export var max_ammo: int
@export var current_ammo: int
@export var inventory: Dictionary = {}
@export var resistances := {DamageInterface.DamageType.CONTACT: 0.0} # 20% contact resistance

signal ammo_changed(current_ammo: int, max_ammo: int)

func _ready():
	# Initialize ItemData database
	ItemData.initialize_database()
	
	# Set up starting ammo from database
	var pistol_ammo_data = ItemData.get_item_by_id("placeholder_pistol_ammo")
	if pistol_ammo_data:
		max_ammo = pistol_ammo_data.stack_size
		current_ammo = 15
	else:
		max_ammo = 30
		current_ammo = 15

func get_resistances() -> Dictionary:
	return resistances

func take_damage(amount: int):
	health = max(0, health - amount)
	if health <= 0:
		# Player doesn't change state like zombies, just dies
		pass # Death handled by PlayerController

func can_shoot() -> bool:
	return current_ammo > 0

func use_ammo():
	current_ammo = max(0, current_ammo - 1)
	ammo_changed.emit(current_ammo, max_ammo) # Add signal emission for UI updates

func add_item(item_id: String, amount: int = 1) -> bool:
	DebugManager.log_debug("PlayerData: add_item() called with item_id='" + item_id + "', amount=" + str(amount))
	
	var item_data = ItemData.get_item_by_id(item_id)
	if not item_data:
		DebugManager.log_debug("PlayerData: Item ID '" + item_id + "' not found in database")
		return false
	
	DebugManager.log_debug("PlayerData: Found item data for '" + item_id + "', type=" + str(item_data.type))
	
	# Handle ammo specifically for current system
	if item_data.type == ItemData.ItemType.AMMO and item_id == "placeholder_pistol_ammo":
		var space_available = max_ammo - current_ammo
		var amount_to_add = min(amount, space_available)
		
		DebugManager.log_debug("PlayerData: Current ammo=" + str(current_ammo) + ", max=" + str(max_ammo) + ", space_available=" + str(space_available))
		
		if amount_to_add > 0:
			current_ammo += amount_to_add
			ammo_changed.emit(current_ammo, max_ammo) # Emit signal for UI update
			DebugManager.log_debug("PlayerData: Added " + str(amount_to_add) + " ammo. Total: " + str(current_ammo))
			return true
		else:
			DebugManager.log_debug("PlayerData: Ammo full, cannot add more")
			return false
	
	DebugManager.log_debug("PlayerData: Item type not handled: " + str(item_data.type))
	return false
