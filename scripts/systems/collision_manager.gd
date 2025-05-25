extends Node

var collision_pool: Array[Area2D] = []
var active_collisions: Dictionary = {}

signal collision_detected(entity_id: int, collider: Node2D)

func _ready():
    # Pre-create collision areas
    for i in range(1000):
        var area = Area2D.new()
        var shape = CollisionShape2D.new()
        var circle = CircleShape2D.new()
        circle.radius = 16
        shape.shape = circle
        area.add_child(shape)
        area.monitoring = true
        area.body_entered.connect(_on_collision_detected.bind(i))
        add_child(area)
        collision_pool.append(area)

func _on_collision_detected(entity_id: int, body: Node2D):
    # Handle collision detection
    collision_detected.emit(entity_id, body)
    
    # Example collision handling based on your roadmap mechanics
    if body.has_method("take_damage"):
        # This could be a zombie hitting the player, or projectile hitting enemy
        body.take_damage(10)
    
    # Remove projectiles on collision
    var entity_manager = get_node("/root/EntityManager")
    if entity_manager:
        var projectile_data = entity_manager.get_projectile_data(entity_id)
        if projectile_data:
            entity_manager.remove_projectile(entity_id)

func assign_collision(entity_id: int, position: Vector2):
    if collision_pool.size() > 0:
        var collision = collision_pool.pop_back()
        collision.position = position
        collision.visible = true
        active_collisions[entity_id] = collision

func remove_collision(entity_id: int):
    if entity_id in active_collisions:
        var collision = active_collisions[entity_id]
        collision.visible = false
        collision_pool.append(collision)
        active_collisions.erase(entity_id)
