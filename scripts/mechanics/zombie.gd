# In zombie.gd - Enhanced damage system
extends CharacterBody2D
class_name Zombie

@export var zombie_data: ZombieData
@export var armor: Resource = null # ArmorData resource
var is_dead: bool = false
var damage_area: Area2D # Store reference to damage area
var player_in_damage_area: bool = false # Track if player is in damage area

func _ready():
	# Initialize ZombieData if not assigned
	if not zombie_data:
		zombie_data = ZombieData.new()
		print("Created new ZombieData - Health: ", zombie_data.health, "/", zombie_data.max_health)
	
	call_deferred("_set_zombie_color") # set color after ready to avoid conflicts with physics state
	# Create damage detection area
	damage_area = Area2D.new()
	damage_area.name = "DamageArea"
	add_child(damage_area)
	
	# Create collision shape for damage area
	var damage_collision = CollisionShape2D.new()
	var damage_shape = CircleShape2D.new()
	damage_shape.radius = 25
	damage_collision.shape = damage_shape
	damage_area.add_child(damage_collision)
	
	# Set collision layers for damage detection
	damage_area.collision_mask = PhysicsLayers.PLAYER
	damage_area.collision_layer = 0
	
	# Connect both enter AND exit signals
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_area.body_exited.connect(_on_damage_area_body_exited)
	
	# add to "zombies" group for tracking
	add_to_group("zombies")

	print("Zombie damage area setup complete")


func _physics_process(delta):
	if not zombie_data:
		return
		
	match zombie_data.state:
		ZombieData.ZombieState.IDLE:
			detect_player()
		ZombieData.ZombieState.CHASING:
			chase_player(delta)

func detect_player():
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) <= zombie_data.sight_range:
		zombie_data.state = ZombieData.ZombieState.CHASING
		call_deferred("_set_zombie_color")

func lose_player():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		zombie_data.state = ZombieData.ZombieState.IDLE
		call_deferred("_set_zombie_color")
		return
	
	var distance = global_position.distance_to(player.global_position)
	var lose_range = zombie_data.sight_range + 50.0
	
	if distance > lose_range:
		zombie_data.state = ZombieData.ZombieState.IDLE
		zombie_data.target_position = Vector2.ZERO
		call_deferred("_set_zombie_color")

func chase_player(delta):
	# First check if we should lose the target
	lose_player()
	
	# Only continue chasing if still in CHASING state
	if zombie_data.state != ZombieData.ZombieState.CHASING:
		return
	
	var direction = get_direction_to_player()
	if direction != Vector2.ZERO:
		velocity = direction * zombie_data.speed
		move_and_slide()
		
		# Update target position for pathfinding
		var player = get_tree().get_first_node_in_group("player")
		if player:
			zombie_data.target_position = player.global_position


func move_toward_target(delta, direction):
	velocity = direction * zombie_data.speed
	move_and_slide()

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
