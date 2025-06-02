# Create new file: scripts/systems/pathfinding_manager.gd
# TODO: Pathfinding system requires optimization and debugging
# Current issues:
# - Causes erratic and unpredictable zombie movement patterns
# - Does not significantly improve navigation around corners as intended
# - Debug path visualization is non-functional
# - Performance impact on entity movement needs evaluation
# System temporarily disabled pending refactoring
extends Node2D
class_name PathfindingManager

var astar: AStar2D
var grid_size: int = 32
var level_bounds: Rect2
var wall_bodies: Array = []

func _ready():
    _initialize_pathfinding()

func _initialize_pathfinding():
    astar = AStar2D.new()
    _scan_level_for_walls()
    _build_navigation_grid()

func _scan_level_for_walls():
    # Get all wall bodies in the scene
    wall_bodies = get_tree().get_nodes_in_group("walls")
    
    # Calculate level bounds
    if wall_bodies.size() > 0:
        var min_pos = wall_bodies[0].global_position
        var max_pos = wall_bodies[0].global_position
        
        for wall in wall_bodies:
            min_pos.x = min(min_pos.x, wall.global_position.x)
            min_pos.y = min(min_pos.y, wall.global_position.y)
            max_pos.x = max(max_pos.x, wall.global_position.x)
            max_pos.y = max(max_pos.y, wall.global_position.y)
        
        level_bounds = Rect2(min_pos - Vector2(200, 200), max_pos - min_pos + Vector2(400, 400))

func _build_navigation_grid():
    var grid_width = int(level_bounds.size.x / grid_size)
    var grid_height = int(level_bounds.size.y / grid_size)
    
    # Add all grid points
    for x in grid_width:
        for y in grid_height:
            var point_id = y * grid_width + x
            var world_pos = level_bounds.position + Vector2(x * grid_size, y * grid_size)
            
            if not _is_position_blocked(world_pos):
                astar.add_point(point_id, world_pos)
    
    # Connect adjacent walkable points
    for x in grid_width:
        for y in grid_height:
            var point_id = y * grid_width + x
            if not astar.has_point(point_id):
                continue
                
            # Check 4-directional connections
            var connections = [
                Vector2(x + 1, y), # Right
                Vector2(x, y + 1), # Down
                Vector2(x - 1, y), # Left
                Vector2(x, y - 1) # Up
            ]
            
            for connection in connections:
                if connection.x >= 0 and connection.x < grid_width and connection.y >= 0 and connection.y < grid_height:
                    var neighbor_id = int(connection.y) * grid_width + int(connection.x)
                    if astar.has_point(neighbor_id):
                        astar.connect_points(point_id, neighbor_id)

func _is_position_blocked(world_pos: Vector2) -> bool:
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsPointQueryParameters2D.new()
    query.position = world_pos
    query.collision_mask = PhysicsLayers.WALLS
    
    var result = space_state.intersect_point(query)
    return result.size() > 0

func find_path(start_pos: Vector2, target_pos: Vector2) -> PackedVector2Array:
    var start_id = _world_to_grid_id(start_pos)
    var target_id = _world_to_grid_id(target_pos)
    
    if start_id == -1 or target_id == -1:
        return PackedVector2Array()
    
    if not astar.has_point(start_id) or not astar.has_point(target_id):
        return PackedVector2Array()
    
    return astar.get_point_path(start_id, target_id)

func _world_to_grid_id(world_pos: Vector2) -> int:
    var local_pos = world_pos - level_bounds.position
    var grid_x = int(local_pos.x / grid_size)
    var grid_y = int(local_pos.y / grid_size)
    
    var grid_width = int(level_bounds.size.x / grid_size)
    var grid_height = int(level_bounds.size.y / grid_size)
    
    if grid_x < 0 or grid_x >= grid_width or grid_y < 0 or grid_y >= grid_height:
        return -1
    
    return grid_y * grid_width + grid_x
