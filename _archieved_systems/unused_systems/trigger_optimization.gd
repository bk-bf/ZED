extends Area3D
class_name OptimizedTrigger

func _ready():
    # Disable unnecessary monitoring for performance
    monitoring = true
    monitorable = false # Most triggers don't need to be detected by others
    
    # Use specific collision layers
    collision_layer = PhysicsLayers.TRIGGERS
    collision_mask = PhysicsLayers.PLAYER # Only detect player
    
    # Optimize shape complexity
    optimize_collision_shape()

func optimize_collision_shape():
    # Use simple shapes for triggers
    var shape = BoxShape3D.new()
    shape.size = Vector3(2, 0.5, 2) # Thin box for room transitions
    $CollisionShape3D.shape = shape
