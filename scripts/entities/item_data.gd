extends Resource
class_name ItemData

@export var id: String
@export var name: String
@export var type: ItemType
@export var stack_size: int = 1

enum ItemType {
	# Combat Items
	AMMO,
	WEAPON,
	ATTACHMENT,
	ARMOR,
	
	# Medical & Consumables
	MEDICAL,
	CONSUMABLE,
	
	# Equipment & Tools
	EQUIPMENT,
	TOOL,
	
	# Resources & Materials
	MATERIAL,
	COMPONENT,
	
	# Valuables & Quest Items
	VALUABLE,
	QUEST_ITEM,
	
	# Containers & Storage
	CONTAINER,
	
	# Special Categories
	KEY,
	DOCUMENT
}


# Static database
static var _item_database: Dictionary = {}
static var _initialized: bool = false

static func initialize_database():
	if _initialized:
		return
	
	# Create basic items
	var placeholder_pistol_ammo = ItemData.new()
	placeholder_pistol_ammo.id = "placeholder_pistol_ammo"
	placeholder_pistol_ammo.name = "Pistol Ammunition"
	placeholder_pistol_ammo.type = ItemType.AMMO
	placeholder_pistol_ammo.stack_size = 25
	
	var placeholder_health_kit = ItemData.new()
	placeholder_health_kit.id = "placeholder_health_kit "
	placeholder_health_kit.name = "Medical Kit"
	placeholder_health_kit.type = ItemType.MEDICAL
	placeholder_health_kit.stack_size = 5
	
	# Add to database
	_item_database[placeholder_pistol_ammo.id] = placeholder_pistol_ammo
	_item_database[placeholder_health_kit.id] = placeholder_health_kit
	
	_initialized = true

static func get_item_by_id(item_id: String) -> ItemData:
	if not _initialized:
		initialize_database()
	
	return _item_database.get(item_id, null)

static func get_items_by_type(item_type: ItemType) -> Array[ItemData]:
	if not _initialized:
		initialize_database()
	
	var filtered_items: Array[ItemData] = []
	for item in _item_database.values():
		if item.type == item_type:
			filtered_items.append(item)
	return filtered_items

static func get_all_items() -> Array[ItemData]:
	if not _initialized:
		initialize_database()
	
	var items: Array[ItemData] = []
	for item in _item_database.values():
		items.append(item)
	return items
