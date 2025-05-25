extends Node

func _ready():
    configure_jolt_performance()

func configure_jolt_performance():
    # Configure for top-down shooter workload
    var settings = {
        "max_bodies": 2048, # Accommodate many zombies + projectiles
        "max_body_pairs": 4096, # Handle collision pairs efficiently
        "max_contact_constraints": 2048, # Limit contact processing
        "stepping_mode": "variable", # Good for 60fps target
        "collision_steps": 1 # Single step sufficient for your game type
    }
    
    apply_jolt_settings(settings)

func apply_jolt_settings(settings: Dictionary):
    # Apply settings through project configuration
    for key in settings:
        ProjectSettings.set_setting("physics/3d/jolt/" + key, settings[key])
