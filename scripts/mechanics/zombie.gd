# In zombie.gd - Enhanced damage system
extends CharacterBody2D
class_name Zombie

@export var zombie_data: ZombieData
var is_dead: bool = false
var damage_area: Area2D # Store reference to damage area

func _ready():
	# Initialize ZombieData if not assigned
	if not zombie_data:
		zombie_data = ZombieData.new()
		print("Created new ZombieData - Health: ", zombie_data.health, "/", zombie_data.max_health)
	
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

var player_in_damage_area: bool = false

func _process(delta):
	# Update damage cooldown
	zombie_data.update_cooldown(delta)
	
	# CONTINUOUS DAMAGE CHECK - this is the key fix
	if player_in_damage_area and zombie_data.can_damage():
		# Check if player is still overlapping (extra safety)
		var overlapping_bodies = damage_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.has_method("take_damage"):
				body.take_damage(zombie_data.damage)
				zombie_data.apply_damage_cooldown()
				print("Zombie damaged player for ", zombie_data.damage, " damage")
				break # Only damage once per cooldown cycle

func _on_damage_area_body_entered(body):
	"""Player entered damage area"""
	if body.has_method("take_damage"):
		player_in_damage_area = true
		# Apply immediate damage on first contact
		if zombie_data.can_damage():
			body.take_damage(zombie_data.damage)
			zombie_data.apply_damage_cooldown()
			print("Zombie initially damaged player for ", zombie_data.damage, " damage")

func _on_damage_area_body_exited(body):
	"""Player left damage area"""
	if body.has_method("take_damage"):
		player_in_damage_area = false
		print("Player left zombie damage area")


func take_damage(amount: int):
	"""Handle damage from bullets - called by bullet's _on_body_entered"""
	if is_dead or not zombie_data.is_alive():
		return
	
	# Register bullet hit with debug manager
	DebugManager.register_bullet_hit()
	
	# Use ZombieData's take_damage method
	zombie_data.take_damage(amount)
	
	# DebugManager - AI category for combat debugging
	DebugManager.debug_print("ai", "Zombie took " + str(amount) + " damage. Health: " + str(zombie_data.health) + "/" + str(zombie_data.max_health))
	
	# Add visual damage feedback
	show_damage_flash()
	
	# Check if zombie died (ZombieData handles state change)
	if not zombie_data.is_alive():
		die()

func show_damage_flash():
	"""Flash zombie white briefly to indicate damage"""
	var color_rect = get_node("CollisionShape2D/ColorRect")
	if color_rect:
		# Flash bright white for damage
		color_rect.modulate = Color.WHITE * 2.0 # Bright white flash
		
		# Return to normal color after brief delay
		await get_tree().create_timer(0.1).timeout
		
		# Only reset if zombie is still alive
		if zombie_data.is_alive() and not is_dead:
			color_rect.modulate = Color.WHITE

func die():
	"""Handle zombie death"""
	if is_dead:
		return
	
	is_dead = true
	
	# Register death with debug manager
	DebugManager.register_zombie_death()
	
	# Visual feedback - change to dark red for death (distinct from damage flash)
	var color_rect = get_node("CollisionShape2D/ColorRect")
	if color_rect:
		color_rect.color = Color.DARK_RED
	
	# Disable collision
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	
	# Remove after brief delay
	await get_tree().create_timer(0.5).timeout
	queue_free()

# Future expansion methods (ready for Day 5 AI)
func get_health_percentage() -> float:
	"""Get health as percentage for UI/AI decisions"""
	return zombie_data.health / float(zombie_data.max_health)
