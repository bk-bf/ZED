# In zombie.gd - Enhanced damage system
extends CharacterBody2D
class_name Zombie

@export var zombie_data: ZombieData
@export var armor: Resource = null # ArmorData resource
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
