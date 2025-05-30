# scripts/systems/fog_of_war.gd
extends Node2D
class_name FogOfWar

@export var fog_color: Color = Color.BLACK
@export var fog_enabled: bool = true
@export var memory_color: Color = Color(0.3, 0.3, 0.3, 0.7)

var player: Node2D
var player_sight_range: Area2D
var fog_canvas: CanvasLayer
var fog_rect: ColorRect

# Track visibility states
var explored_areas: Dictionary = {}
var currently_visible_entities: Array = []

func _ready():
    _setup_fog_canvas()
    _find_player_and_sight_range()
    _connect_sight_signals()

func _process(_delta):
    if not fog_enabled or not player:
        return
        
    if player_sight_range:
        # Simple approach: hide fog rect when player is present
        # This creates basic "all visible" vs "all hidden" fog
        fog_rect.modulate.a = 0.0 # Make fog transparent when player exists
    else:
        fog_rect.modulate.a = 1.0 # Keep fog opaque when no player

func _setup_fog_canvas():
    fog_canvas = CanvasLayer.new()
    fog_canvas.layer = 10
    add_child(fog_canvas)
    
    fog_rect = ColorRect.new()
    fog_rect.color = fog_color
    fog_rect.size = get_viewport().get_visible_rect().size
    fog_rect.position = Vector2.ZERO
    fog_canvas.add_child(fog_rect)

func _find_player_and_sight_range():
    player = get_tree().get_first_node_in_group("player")
    if player:
        player_sight_range = player.get_node("SightRange")
        if not player_sight_range:
            print("Warning: Player SightRange not found!")
        else:
            # Configure player sight range collision layers
            player_sight_range.collision_layer = 0 # Not on any layer
            player_sight_range.collision_mask = PhysicsLayers.ENEMIES | PhysicsLayers.PICKUPS # Detect enemies and pickups

func _connect_sight_signals():
    if player_sight_range:
        player_sight_range.body_entered.connect(_on_entity_entered_sight)
        player_sight_range.body_exited.connect(_on_entity_left_sight)
        player_sight_range.area_entered.connect(_on_area_entered_sight)
        player_sight_range.area_exited.connect(_on_area_left_sight)

func _on_entity_entered_sight(body):
    # Entity becomes visible
    if body not in currently_visible_entities:
        currently_visible_entities.append(body)
        _show_entity(body)
        _mark_area_explored(body.global_position)

func _on_entity_left_sight(body):
    # Entity leaves sight - move to memory state
    if body in currently_visible_entities:
        currently_visible_entities.erase(body)
        _hide_entity(body)

func _on_area_entered_sight(area):
    # Handle Area2D objects (pickups, etc.)
    _mark_area_explored(area.global_position)

func _on_area_left_sight(area):
    # Handle areas leaving sight
    pass

func _show_entity(entity):
    # Make entity fully visible
    entity.modulate = Color.WHITE

func _hide_entity(entity):
    # Hide entity or show as memory
    if _is_area_explored(entity.global_position):
        entity.modulate = memory_color # Show as faded memory
    else:
        entity.modulate = Color.TRANSPARENT # Completely hidden

func _mark_area_explored(pos: Vector2):
    # Mark area as explored (simplified grid system)
    var grid_pos = Vector2(int(pos.x / 64), int(pos.y / 64)) # 64-pixel grid
    explored_areas[grid_pos] = true

func _is_area_explored(pos: Vector2) -> bool:
    var grid_pos = Vector2(int(pos.x / 64), int(pos.y / 64))
    return explored_areas.get(grid_pos, false)

func get_visible_entities() -> Array:
    return currently_visible_entities

func is_position_visible(pos: Vector2) -> bool:
    if not player_sight_range:
        return false
    
    # Create a physics query to check if position is within sight range
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsPointQueryParameters2D.new()
    query.position = pos
    query.collision_mask = player_sight_range.collision_mask
    
    var result = space_state.intersect_point(query)
    for body in result:
        if body.collider == player_sight_range:
            return true
    return false
