# scripts/managers/spawn_manager.gd
extends Node
class_name SpawnManager

@export var zombie_scene: PackedScene
@export var spawn_on_ready: bool = true
@export var max_zombies: int = 50
@export var walker_percentage: float = 0.7
@export var runner_percentage: float = 0.2
@export var brute_percentage: float = 0.1

func _ready():
    if spawn_on_ready:
        spawn_test_zombies()

func spawn_test_zombies():
    var spawn_areas = get_tree().get_nodes_in_group("spawn_areas")
    if spawn_areas.is_empty():
        print("No spawn areas found!")
        return
    
    # Calculate random spawn count between max_zombies - 3 and max_zombies
    var spawn_count = randi_range(max_zombies - 3, max_zombies)
    
    # Calculate how many zombies of each type to spawn based on percentages
    var walker_count = int(spawn_count * walker_percentage)
    var runner_count = int(spawn_count * runner_percentage)
    var brute_count = int(spawn_count * brute_percentage)
    
    # Handle rounding differences - add remaining zombies to walkers
    var total_assigned = walker_count + runner_count + brute_count
    walker_count += spawn_count - total_assigned
    
    print("Spawning ", spawn_count, " zombies: ", walker_count, " Walkers, ", runner_count, " Runners, ", brute_count, " Brutes")
    
    # Spawn each type
    spawn_zombie_type(EntitiesType.ZombieType.WALKER, walker_count, spawn_areas)
    spawn_zombie_type(EntitiesType.ZombieType.RUNNER, runner_count, spawn_areas)
    spawn_zombie_type(EntitiesType.ZombieType.BRUTE, brute_count, spawn_areas)

func spawn_zombie_type(type: EntitiesType.ZombieType, count: int, spawn_areas: Array):
    for i in range(count):
        spawn_zombie_at_random_area(type, spawn_areas)

func spawn_zombie_at_random_area(type: EntitiesType.ZombieType, spawn_areas: Array):
    var spawn_area = spawn_areas.pick_random()
    var spawn_position = get_random_position_in_area(spawn_area)
    
    var zombie = zombie_scene.instantiate()
    
    # Ensure zombie_data is initialized before setting type
    if not zombie.zombie_data:
        zombie.zombie_data = ZombieData.new()
    
    zombie.zombie_data.zombie_type = type
    zombie.zombie_data._setup_type_stats()
    zombie.global_position = spawn_position
    
    # Use call_deferred to add child after scene initialization
    get_tree().current_scene.call_deferred("add_child", zombie)
   # print("Spawned ", EntitiesType.get_zombie_type_name(type), " at ", spawn_position)

func get_random_position_in_area(area: Area2D) -> Vector2:
    var collision_shape = area.get_node("CollisionShape2D")
    if collision_shape.shape is CircleShape2D:
        var circle = collision_shape.shape as CircleShape2D
        # Generate random position within circle
        var angle = randf() * TAU # Random angle
        var distance = randf() * circle.radius # Random distance from center
        var offset = Vector2(cos(angle), sin(angle)) * distance
        return area.global_position + offset
    elif collision_shape.shape is RectangleShape2D:
        var rect = collision_shape.shape as RectangleShape2D
        var random_x = randf_range(-rect.size.x / 2, rect.size.x / 2)
        var random_y = randf_range(-rect.size.y / 2, rect.size.y / 2)
        return area.global_position + Vector2(random_x, random_y)
    
    return area.global_position # Fallback to center
