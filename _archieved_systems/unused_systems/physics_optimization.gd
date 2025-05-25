extends Node

func optimize_rigidbody(body: RigidBody3D, object_type: String):
    match object_type:
        "projectile":
            # High-speed, short-lived objects
            body.continuous_cd = true # Prevent tunneling
            body.max_contacts_reported = 1 # Minimal contact info needed
            body.contact_monitor = true
            body.gravity_scale = 0.5 # Slight arc for visual appeal
            
        "zombie":
            # Many AI-controlled entities
            body.continuous_cd = false # Not needed for slower objects
            body.max_contacts_reported = 3
            body.contact_monitor = true
            body.can_sleep = true # Allow sleeping when stationary
            
        "loot":
            # Static until picked up
            body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
            body.can_sleep = true
            body.contact_monitor = false # No collision response needed
