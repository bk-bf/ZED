extends Node2D
class_name PlayerSight

@export var sight_range: float = 100.0

var player: Node2D
var sight_area: Area2D
var visible_entities: Array = []
var entities_in_range: Array = [] # Track all entities in sight range
var memory_entities: Dictionary = {} # Track entities in memory with their last known positions
var explored_areas: Dictionary = {}

# debug circle for sight range visualization
@export var debug_enabled: bool = true
@export var debug_zombie_sight_enabled: bool = true # This is the master control
var debug_circle: CircleShape2D

func _ready():
	add_to_group("player_sight")
	_find_player_and_sight_area()
	_connect_sight_signals()
	# Wait one frame for all zombies to be ready, then inidtialize visibility
	await get_tree().process_frame
	_initialize_all_zombie_visibility()

# debug visualization
func _input(event):
	# New zombie sight debug toggle
	if event.is_action_pressed("debug_zombie_sight"):
		debug_zombie_sight_enabled = !debug_zombie_sight_enabled
		_toggle_all_zombie_sight_debug()
		print("Zombie sight debug: ", "ON" if debug_zombie_sight_enabled else "OFF")

func _toggle_all_zombie_sight_debug():
	var zombies = get_tree().get_nodes_in_group("zombies")
	for zombie in zombies:
		if zombie.has_method("set_debug_sight"):
			zombie.set_debug_sight(debug_zombie_sight_enabled)

func _toggle_sight_range_visual():
	queue_redraw() # Trigger _draw() to be called

func _draw():
	if debug_enabled and player and sight_area:
		var player_local_pos = to_local(player.global_position)
		
		# Get the actual radius from the player's SightRange CollisionShape2D
		var actual_radius = _get_sight_area_radius()
		if actual_radius > 0:
			# Draw filled circle (more transparent - was 0.1, now 0.05)
			draw_circle(player_local_pos, actual_radius, Color(0, 1, 0, 0.05))
			# Draw circle outline (more transparent - was 0.8, now 0.4)
			draw_arc(player_local_pos, actual_radius, 0, TAU, 64, Color(0, 1, 0, 0.4), 2.0)

func _get_sight_area_radius() -> float:
	"""Get the actual radius from the player's SightRange Area2D"""
	if not sight_area:
		return 0.0
	
	var collision_shape = sight_area.get_node("CollisionShape2D")
	if not collision_shape:
		return 0.0
	
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		return shape.radius
	elif shape is RectangleShape2D:
		# For rectangle shapes, use the larger dimension as radius
		return max(shape.size.x, shape.size.y) / 2.0
	
	# Fallback to the exported variable
	return sight_range

func _initialize_all_zombie_visibility():
	"""Initialize visibility for all zombies based on line of sight"""
	var zombies = get_tree().get_nodes_in_group("zombies")
	for zombie in zombies:
		# Check if zombie should be initially visible
		if _is_entity_in_sight_range(zombie) and _has_line_of_sight(zombie):
			if zombie not in visible_entities:
				visible_entities.append(zombie)
			if zombie not in entities_in_range:
				entities_in_range.append(zombie)
			_show_entity(zombie)
			_mark_area_explored(zombie.global_position)
		else:
			_hide_entity(zombie)

func _process(_delta):
	# Handle memory entities - keep them frozen at their memory positions
	for entity in memory_entities:
		if entity and is_instance_valid(entity):
			entity.global_position = memory_entities[entity]
	
	# Continuously check line-of-sight for visible entities
	for entity in visible_entities.duplicate():
		if not _has_line_of_sight(entity):
			visible_entities.erase(entity)
			_hide_entity(entity)
	
	# Continuously check line-of-sight for ALL entities in sight range
	for entity in entities_in_range.duplicate():
		var has_los = _has_line_of_sight(entity)
		var is_visible = entity in visible_entities
		var is_in_memory = entity in memory_entities
		
		if has_los and not is_visible and not is_in_memory:
			# Entity came from behind wall - make visible and remove from memory
			visible_entities.append(entity)
			_remove_from_memory(entity)
			_show_entity(entity)
			_mark_area_explored(entity.global_position)
		elif not has_los and is_visible:
			# Entity went behind wall - hide but keep in range
			visible_entities.erase(entity)
			# Don't immediately add to memory - let the entity movement handle it
			if _is_area_explored(entity.global_position):
				_add_to_memory(entity)
			else:
				_hide_entity_completely(entity)
	
	# Redraw debug circle if enabled (follows player)
	if debug_enabled:
		queue_redraw()

func _find_player_and_sight_area():
	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("PlayerSight: No player found!")
		return
	
	sight_area = player.get_node("SightRange")
	if not sight_area:
		print("PlayerSight: No SightRange found on player!")

func _connect_sight_signals():
	if not sight_area:
		return
	
	sight_area.body_entered.connect(_on_entity_entered_sight)
	sight_area.body_exited.connect(_on_entity_left_sight)

func _on_entity_entered_sight(body):
	if not body.is_in_group("zombies"):
		return
	
	# Add to entities in range regardless of line of sight
	if body not in entities_in_range:
		entities_in_range.append(body)
	
	# Remove from memory if it was there
	_remove_from_memory(body)
	
	# Only make visible if there's line of sight
	if _has_line_of_sight(body):
		if body not in visible_entities:
			visible_entities.append(body)
			_show_entity(body)
			_mark_area_explored(body.global_position)
	else:
		# In range but behind wall - hide it (but don't add to memory yet)
		_hide_entity_completely(body)

func _on_entity_left_sight(body):
	if not body.is_in_group("zombies"):
		return
	
	# Store current position before removing from tracking
	var last_position = body.global_position
	
	# Remove from both tracking arrays
	if body in entities_in_range:
		entities_in_range.erase(body)
	if body in visible_entities:
		visible_entities.erase(body)
	
	# Add to memory if area was explored, otherwise hide completely
	if _is_area_explored(last_position):
		memory_entities[body] = last_position
		_add_to_memory(body)
	else:
		_hide_entity_completely(body)

func _is_entity_in_sight_range(entity) -> bool:
	if not sight_area:
		return false
	return sight_area.overlaps_body(entity)

func _has_line_of_sight(target) -> bool:
	if not player or not target:
		return false
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		player.global_position,
		target.global_position
	)
	query.collision_mask = PhysicsLayers.WALLS
	query.exclude = [player]
	
	var result = space_state.intersect_ray(query)
	return result.is_empty()

func _show_entity(entity):
	# Make entity fully visible with normal color
	entity.visible = true
	entity.modulate = Color.WHITE

func _hide_entity(entity):
	if _is_area_explored(entity.global_position):
		# Add to memory instead of showing darkened version immediately
		_add_to_memory(entity)
	else:
		# Completely hidden
		_hide_entity_completely(entity)

func _hide_entity_completely(entity):
	"""Completely hide entity - no memory, no visibility"""
	entity.visible = false
	entity.modulate = Color.WHITE

func _add_to_memory(entity):
	"""Add entity to memory system with frozen position"""
	if not _is_area_explored(entity.global_position):
		_hide_entity_completely(entity)
		return
	
	# Store the entity's last known position if not already stored
	if entity not in memory_entities:
		memory_entities[entity] = entity.global_position
	
	# Show as memory - darkened and at frozen position
	entity.visible = true
	entity.modulate = Color(0.4, 0.4, 0.4, 1.0)
	# Position will be set in _process() continuously

func _remove_from_memory(entity):
	"""Remove entity from memory system"""
	if entity in memory_entities:
		memory_entities.erase(entity)

func _mark_area_explored(pos: Vector2):
	var grid_pos = Vector2(int(pos.x / 64), int(pos.y / 64))
	explored_areas[grid_pos] = true

func _is_area_explored(pos: Vector2) -> bool:
	var grid_pos = Vector2(int(pos.x / 64), int(pos.y / 64))
	return explored_areas.get(grid_pos, false)

# Debug method to check system status
func get_debug_info() -> Dictionary:
	return {
		"entities_in_range": entities_in_range.size(),
		"visible_entities": visible_entities.size(),
		"memory_entities": memory_entities.size(),
		"explored_areas": explored_areas.size()
	}
