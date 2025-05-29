# In zombie.gd - Enhanced damage system
extends CharacterBody2D
class_name Zombie

@export var zombie_data: ZombieData
@export var armor: Resource = null # ArmorData resource
var is_dead: bool = false
var damage_area: Area2D # Store reference to damage area
var player_in_damage_area: bool = false # Track if player is in damage area


func _ready():
	_initialize_zombie_data()
	_setup_damage_area()
	_setup_sight_range()
	_setup_collision_layers()
	_setup_visual_state()
	add_to_group("zombies")

func _initialize_zombie_data():
	if not zombie_data:
		zombie_data = ZombieData.new()
		print("Created new ZombieData - Health: ", zombie_data.health, "/", zombie_data.max_health)

func _setup_damage_area():
	damage_area = Area2D.new()
	damage_area.name = "DamageArea"
	add_child(damage_area)
	
	var damage_collision = CollisionShape2D.new()
	var damage_shape = CircleShape2D.new()
	damage_shape.radius = 25
	damage_collision.shape = damage_shape
	damage_area.add_child(damage_collision)
	
	damage_area.collision_mask = PhysicsLayers.PLAYER
	damage_area.collision_layer = 0
	
	_connect_damage_signals()

func _setup_sight_range():
	var sight_range = $SightRange
	sight_range.collision_layer = 0
	sight_range.collision_mask = PhysicsLayers.PLAYER
	
	_connect_sight_signals()

func _setup_collision_layers():
	collision_layer = PhysicsLayers.ENEMIES
	collision_mask = PhysicsLayers.PLAYER | PhysicsLayers.WALLS

func _setup_visual_state():
	call_deferred("_set_zombie_color")

func _connect_damage_signals():
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_area.body_exited.connect(_on_damage_area_body_exited)

func _connect_sight_signals():
	var sight_range = $SightRange
	sight_range.body_entered.connect(_on_player_entered_sight)
	sight_range.body_exited.connect(_on_player_left_sight)
	
func _on_player_entered_sight(body):
	if body.is_in_group("player") and _has_line_of_sight(body):
		zombie_data.state = ZombieData.ZombieState.CHASING
		zombie_data.target_position = body.global_position
		call_deferred("_set_zombie_color")

func _has_line_of_sight(player) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)
	query.collision_mask = PhysicsLayers.WALLS # Only check for walls
	query.exclude = [self] # Don't hit the zombie itself
	
	var result = space_state.intersect_ray(query)
	return result.is_empty() # True if no walls block the view

func _on_player_left_sight(body):
	if body.is_in_group("player"):
		# Don't immediately go IDLE - we have a target position to search
		# The chase_player method will handle reaching the target
		pass

func _physics_process(delta):
	if not zombie_data:
		return
		
	match zombie_data.state:
		ZombieData.ZombieState.IDLE:
			# Do nothing - wait for sight range signal
			pass
		ZombieData.ZombieState.CHASING:
			chase_target(delta)


func _get_avoidance_direction(target_direction: Vector2) -> Vector2:
	var space_state = get_world_2d().direct_space_state
	
	# Check if direct path is blocked
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + target_direction * 64.0 # Look ahead 64 pixels
	)
	query.collision_mask = PhysicsLayers.WALLS
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		# Direct path is clear
		return target_direction
	
	# Path is blocked, try left and right alternatives
	var left_direction = target_direction.rotated(-PI / 3) # 60 degrees left
	var right_direction = target_direction.rotated(PI / 3) # 60 degrees right
	
	# Test left path
	query.to = global_position + left_direction * 64.0
	var left_result = space_state.intersect_ray(query)
	
	# Test right path  
	query.to = global_position + right_direction * 64.0
	var right_result = space_state.intersect_ray(query)
	
	# Choose the clearest path
	if left_result.is_empty() and right_result.is_empty():
		# Both paths clear, choose randomly to prevent predictable behavior
		return left_direction if randf() > 0.5 else right_direction
	elif left_result.is_empty():
		return left_direction
	elif right_result.is_empty():
		return right_direction
	else:
		# Both blocked, try sharper angles
		return target_direction.rotated(PI / 2) # 90 degree turn

func chase_target(delta):
	var player = get_tree().get_first_node_in_group("player")
	
	if player and _is_player_in_sight_range(player) and _has_line_of_sight(player):
		# Player is visible - chase directly with obstacle avoidance
		var target_direction = (player.global_position - global_position).normalized()
		var movement_direction = _get_avoidance_direction(target_direction)
		velocity = movement_direction * zombie_data.speed
		zombie_data.target_position = player.global_position
		
	elif zombie_data.target_position != Vector2.ZERO:
		# Player not visible - move to last known position with avoidance
		var target_direction = (zombie_data.target_position - global_position).normalized()
		var movement_direction = _get_avoidance_direction(target_direction)
		velocity = movement_direction * zombie_data.speed * 0.7
		
		if global_position.distance_to(zombie_data.target_position) < 32.0:
			zombie_data.target_position = Vector2.ZERO
			zombie_data.state = ZombieData.ZombieState.IDLE
			call_deferred("_set_zombie_color")
	else:
		zombie_data.state = ZombieData.ZombieState.IDLE
		call_deferred("_set_zombie_color")
	
	move_and_slide()


func _is_player_in_sight_range(player) -> bool:
	var sight_range = $SightRange
	return sight_range.overlaps_body(player)


func _process(delta):
	zombie_data.update_cooldown(delta)
	
	if player_in_damage_area && zombie_data.can_damage():
		var overlapping = $DamageArea.get_overlapping_bodies()
		for body in overlapping:
			if body is PlayerController:
				DamageInterface.apply_damage(
					self,
					body,
					zombie_data.damage,
					DamageInterface.DamageType.CONTACT
				)
				zombie_data.apply_damage_cooldown()
				break # Only damage once per cooldown cycle


func _on_damage_area_body_entered(body):
	if body is PlayerController:
		player_in_damage_area = true
		if zombie_data.can_damage():
			DamageInterface.apply_damage(
				self,
				body,
				zombie_data.damage,
				DamageInterface.DamageType.CONTACT
			)
			zombie_data.apply_damage_cooldown()

func _on_damage_area_body_exited(body):
	if body is PlayerController:
		player_in_damage_area = false


func get_resistances() -> Dictionary:
	return zombie_data.get_resistances() if zombie_data else {}

# it is just impossible to outsource this method
func take_damage(amount: int, damage_type: DamageInterface.DamageType):
	if is_dead or not zombie_data.is_alive():
		return

	var resistances = get_resistances()
	var resistance = resistances.get(damage_type, 0.0)
	var final_damage = int(amount * (1.0 - resistance))
	zombie_data.take_damage(final_damage)

	show_damage_flash()

	if zombie_data.health <= 0 and not is_dead:
		die()

func die():
	"""Handle zombie death"""
	if is_dead:
		return
	
	is_dead = true
	zombie_data.state = ZombieData.ZombieState.DEAD # Set state first
	
	# Register death with debug manager
	DebugManager.register_zombie_death()
	
	# Visual feedback using consistent color system
	call_deferred("_set_zombie_color")
	
	# Disable collision
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	
	# call loot drop
	var loot_drops = zombie_data.get_loot_drops()
	for drop in loot_drops:
		print("Dropped ", drop["amount"], " of ", drop["item_id"])

	# drop an item pickup at zombie's death position - DEFER THIS
	call_deferred("_create_pickups")
	
	# Remove after brief delay
	await get_tree().create_timer(0.5).timeout
	queue_free()


func _create_pickups():
	# Update ZombieData with current world position before creating pickups
	zombie_data.position = global_position
	"""Create pickup items - called deferred to avoid physics state conflicts"""
	var pickup_items = zombie_data.create_pickup_items()
	
	for pickup_item in pickup_items:
		# Load the scene and instantiate it
		var pickup_scene = preload("res://scenes/gameplay/items/item_pickup.tscn")
		var pickup_instance = pickup_scene.instantiate()
		
		# Setup the pickup with data
		pickup_instance.setup(
			pickup_item["item_id"],
			pickup_item["amount"],
			pickup_item["position"]
		)
		
		# Add to scene
		get_tree().current_scene.add_child(pickup_instance)

	
# Future expansion methods (ready for Day 5 AI)
func get_health_percentage() -> float:
	"""Get health as percentage for UI/AI decisions"""
	return zombie_data.health / float(zombie_data.max_health)

func get_direction_to_player() -> Vector2:
	# Get the player node from the scene
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("Warning: No player found in scene")
		return Vector2.ZERO
	
	# Calculate direction vector from zombie to player
	var direction = (player.global_position - global_position).normalized()
	return direction


func show_damage_flash():
	"""Flash zombie white briefly to indicate damage"""
	var color_rect = get_node("CollisionShape2D/ColorRect")
	if color_rect:
		# Flash bright white for damage
		color_rect.modulate = Color.WHITE * 2.0 # Bright white flash
		
		# Return to normal color after brief delay
		await get_tree().create_timer(0.1).timeout
		
		# Only reset if zombie is still alive - use centralized color system
		if zombie_data.is_alive() and not is_dead:
			color_rect.modulate = Color.WHITE # Reset modulation
			call_deferred("_set_zombie_color") # Apply correct state color


func _set_zombie_color():
	var color_rect = $CollisionShape2D/ColorRect
	if not color_rect:
		print("Warning: ColorRect not found in zombie")
		return
	
	match zombie_data.state:
		ZombieData.ZombieState.IDLE:
			color_rect.color = Color.PURPLE
		ZombieData.ZombieState.CHASING:
			color_rect.color = Color.DARK_GREEN
		ZombieData.ZombieState.ATTACKING:
			color_rect.color = Color.ORANGE
		ZombieData.ZombieState.DEAD:
			color_rect.color = Color.DARK_RED
		_:
			color_rect.color = Color.RED
