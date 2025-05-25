extends Node

func _ready():
    # Only configure what we understand and need
    if ProjectSettings.get_setting("physics/3d/physics_engine") == "Jolt Physics":
        print("Jolt Physics active - basic configuration applied")
        # Add specific settings only when you encounter performance issues
