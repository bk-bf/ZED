# scripts/mechanics/zombie.gd
extends CharacterBody2D
class_name Zombie

# Health properties
@export var max_health: int = 100
@export var health: int = 100

var is_dead: bool = false

func _ready():
	# Set up collision layers for zombie
	collision_layer = PhysicsLayers.ENEMIES # Layer 2 - zombie exists here
	collision_mask = PhysicsLayers.PLAYER | PhysicsLayers.WALLS # What zombie collides with
	
	# Register zombie spawn with debug manager
	DebugManager.register_zombie()

	# Local debug - always useful for scene setup
	print("Zombie ready with health: ", health, " at position: ", global_position)


func take_damage(amount: int):
	"""Handle damage from bullets - called by bullet's _on_body_entered"""
	if is_dead:
		return
	
	# Register bullet hit with debug manager
	DebugManager.register_bullet_hit()
	
	health = max(0, health - amount)
	
	# DebugManager - AI category for combat debugging
	DebugManager.debug_print("ai", "Zombie took " + str(amount) + " damage. Health: " + str(health) + "/" + str(max_health))
	
	if health <= 0:
		die()


func die():
	"""Handle zombie death"""
	if is_dead:
		return
	
	is_dead = true
	
	# Register death with debug manager BEFORE visual feedback
	DebugManager.register_zombie_death()
	
	# Visual feedback
	var color_rect = get_node("CollisionShape2D/ColorRect")
	if color_rect:
		color_rect.color = Color.DARK_RED
	
	# Disable collision
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	
	# Remove after brief delay
	await get_tree().create_timer(0.5).timeout
	queue_free()

func is_alive() -> bool:
	"""Check if zombie is still alive"""
	return health > 0 and not is_dead

# Future expansion methods (ready for Day 5 AI)
func get_health_percentage() -> float:
	"""Get health as percentage for UI/AI decisions"""
	return float(health) / float(max_health)
