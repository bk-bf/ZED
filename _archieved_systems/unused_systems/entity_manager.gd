extends Node
class_name EntityManager

# MultiMesh references
var zombie_multimesh: MultiMeshInstance2D
var player_multimesh: MultiMeshInstance2D
var projectile_multimesh: MultiMeshInstance2D
var loot_multimesh: MultiMeshInstance2D

# Entity data arrays
var active_zombies: Array[ZombieData] = []
var active_projectiles: Array[ProjectileData] = []
var active_loot: Array[LootData] = []
var player_data: PlayerData

# Instance tracking
var next_zombie_id: int = 0
var next_projectile_id: int = 0
var next_loot_id: int = 0

func _ready():
    setup_multimesh_references()
    initialize_player()

func setup_multimesh_references():
    var placeholder_manager = get_node("/root/PlaceholderManager")
    zombie_multimesh = placeholder_manager.entity_multimeshes["zombie"]
    player_multimesh = placeholder_manager.entity_multimeshes["player"]
    projectile_multimesh = placeholder_manager.entity_multimeshes["projectile"]
    loot_multimesh = placeholder_manager.entity_multimeshes["loot"]

func initialize_player():
    player_data = PlayerData.new()
    player_data.instance_id = 0
    player_data.position = Vector2(400, 300) # Starting position
    update_player_transform()

func spawn_zombie(position: Vector2) -> int:
    var zombie_data = ZombieData.new()
    zombie_data.instance_id = next_zombie_id
    zombie_data.position = position
    zombie_data.health = 100
    zombie_data.speed = randf_range(40.0, 60.0) # Slight variation
    
    active_zombies.append(zombie_data)
    update_zombie_transform(zombie_data.instance_id, position)
    
    next_zombie_id += 1
    return zombie_data.instance_id

func spawn_projectile(start_pos: Vector2, direction: Vector2, speed: float = 300.0) -> int:
    var projectile_data = ProjectileData.new()
    projectile_data.instance_id = next_projectile_id
    projectile_data.position = start_pos
    projectile_data.velocity = direction.normalized() * speed
    projectile_data.damage = 25
    
    active_projectiles.append(projectile_data)
    update_projectile_transform(projectile_data.instance_id, start_pos)
    
    next_projectile_id += 1
    return projectile_data.instance_id

func spawn_loot(position: Vector2, item_type: String, quantity: int = 1) -> int:
    var loot_data = LootData.new()
    loot_data.instance_id = next_loot_id
    loot_data.position = position
    loot_data.item_type = item_type
    loot_data.quantity = quantity
    
    active_loot.append(loot_data)
    update_loot_transform(loot_data.instance_id, position)
    
    next_loot_id += 1
    return loot_data.instance_id

func update_zombie_transform(instance_id: int, position: Vector2, rotation: float = 0.0):
    if instance_id < zombie_multimesh.multimesh.instance_count:
        zombie_multimesh.multimesh.set_instance_transform_2d(
            instance_id,
            Transform2D(rotation, position)
        )

func update_player_transform():
    player_multimesh.multimesh.set_instance_transform_2d(
        0,
        Transform2D(0, player_data.position)
    )

func update_projectile_transform(instance_id: int, position: Vector2):
    if instance_id < projectile_multimesh.multimesh.instance_count:
        projectile_multimesh.multimesh.set_instance_transform_2d(
            instance_id,
            Transform2D(0, position)
        )

func update_loot_transform(instance_id: int, position: Vector2):
    if instance_id < loot_multimesh.multimesh.instance_count:
        loot_multimesh.multimesh.set_instance_transform_2d(
            instance_id,
            Transform2D(0, position)
        )

func remove_zombie(instance_id: int):
    for i in range(active_zombies.size()):
        if active_zombies[i] and active_zombies[i].instance_id == instance_id:
            active_zombies[i] = null
            # Hide by scaling to zero
            zombie_multimesh.multimesh.set_instance_transform_2d(
                instance_id,
                Transform2D.IDENTITY.scaled(Vector2.ZERO)
            )
            break

func remove_projectile(instance_id: int):
    for i in range(active_projectiles.size()):
        if active_projectiles[i] and active_projectiles[i].instance_id == instance_id:
            active_projectiles[i] = null
            projectile_multimesh.multimesh.set_instance_transform_2d(
                instance_id,
                Transform2D.IDENTITY.scaled(Vector2.ZERO)
            )
            break

func get_zombie_data(instance_id: int) -> ZombieData:
    for zombie in active_zombies:
        if zombie and zombie.instance_id == instance_id:
            return zombie
    return null

# Helper function to get the count of active zombies
func get_active_zombie_count() -> int:
    var count = 0
    for zombie in active_zombies:
        if zombie and zombie.is_alive():
            count += 1
    return count

func get_projectile_data(instance_id: int) -> ProjectileData:
    for projectile in active_projectiles:
        if projectile and projectile.instance_id == instance_id:
            return projectile
    return null

func get_active_projectile_count() -> int:
    var count = 0
    for projectile in active_projectiles:
        if projectile and projectile.is_active:
            count += 1
    return count

func get_performance_stats() -> Dictionary:
    return {
        "active_zombies": get_active_zombie_count(),
        "active_projectiles": get_active_projectile_count(),
        "total_entities": active_zombies.size() + active_projectiles.size() + active_loot.size()
    }
