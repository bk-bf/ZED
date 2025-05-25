extends Node

func _ready():
    configure_jolt_physics()

func configure_jolt_physics():
    # Optimize for top-down shooter with many small objects
    var physics_server = PhysicsServer3D
    
    # Set gravity appropriate for top-down view
    physics_server.area_set_param(
        get_viewport().world_3d.space,
        PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR,
        Vector3(0, -9.8, 0) # Standard gravity for realistic projectile arcs
    )
    
    # Optimize collision detection for many small objects
    physics_server.set_active(true)
