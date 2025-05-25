extends Control

@onready var fps_label = $VBoxContainer/FPSLabel
@onready var physics_label = $VBoxContainer/PhysicsLabel

func _ready():
    if not OS.is_debug_build():
        visible = false

func _process(_delta):
    if visible:
        fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
        
        var physics_info = get_physics_info()
        physics_label.text = "Bodies: %d | Contacts: %d" % [
            physics_info.active_bodies,
            physics_info.contact_count
        ]

func get_physics_info() -> Dictionary:
    var space = get_viewport().world_3d.space
    var physics_server = PhysicsServer3D
    
    return {
        "active_bodies": physics_server.space_get_direct_state(space).get_contact_count(),
        "contact_count": physics_server.space_get_direct_state(space).get_contact_count()
    }
