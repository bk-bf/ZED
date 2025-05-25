extends Control

@onready var entity_count_label = $VBoxContainer/EntityCount
@onready var fps_label = $VBoxContainer/FPS
@onready var draw_calls_label = $VBoxContainer/DrawCalls
@onready var memory_label = $VBoxContainer/Memory

func _ready():
    if not OS.is_debug_build():
        visible = false

func _process(_delta):
    if visible:
        update_performance_display()

func update_performance_display():
    # FPS monitoring
    fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
    
    # Entity count from your EntityManager
    var entity_manager = get_node_or_null("/root/EntityManager")
    if entity_manager:
        var zombie_count = entity_manager.get_active_zombie_count()
        var projectile_count = entity_manager.active_projectiles.size()
        entity_count_label.text = "Entities: Z:%d P:%d" % [zombie_count, projectile_count]
    
    # Draw calls using correct Godot 4.4 API
    update_draw_call_info()
    
    # Memory usage
    var memory_usage = Performance.get_monitor(Performance.MEMORY_STATIC)
    memory_label.text = "Memory: %.1f MB" % (memory_usage / 1024.0 / 1024.0)

func update_draw_call_info():
    # Get viewport RID for render info
    var viewport = get_viewport()
    var viewport_rid = viewport.get_viewport_rid()
    
    # Use the correct API from search results
    var visible_draw_calls = RenderingServer.viewport_get_render_info(
        viewport_rid,
        RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE,
        RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME
    )
    
    var shadow_draw_calls = RenderingServer.viewport_get_render_info(
        viewport_rid,
        RenderingServer.VIEWPORT_RENDER_INFO_TYPE_SHADOW,
        RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME
    )
    
    var total_draw_calls = visible_draw_calls + shadow_draw_calls
    draw_calls_label.text = "Draw Calls: %d (V:%d S:%d)" % [total_draw_calls, visible_draw_calls, shadow_draw_calls]

# Additional performance monitoring for your specific game
func get_multimesh_performance() -> Dictionary:
    var placeholder_manager = get_node_or_null("/root/PlaceholderManager")
    if not placeholder_manager:
        return {}
    
    var performance_data = {}
    
    # Check MultiMesh instance counts
    for entity_type in placeholder_manager.entity_multimeshes:
        var multimesh_instance = placeholder_manager.entity_multimeshes[entity_type]
        var multimesh = multimesh_instance.multimesh
        performance_data[entity_type] = {
            "max_instances": multimesh.instance_count,
            "visible_instances": count_visible_instances(multimesh)
        }
    
    return performance_data

func count_visible_instances(multimesh: MultiMesh) -> int:
    var visible_count = 0
    for i in range(multimesh.instance_count):
        var transform = multimesh.get_instance_transform_2d(i)
        # Check if instance is not scaled to zero (our hiding method)
        if transform.get_scale() != Vector2.ZERO:
            visible_count += 1
    return visible_count
