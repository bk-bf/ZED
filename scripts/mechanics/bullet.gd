# scripts/mechanics/bullet.gd
extends Area2D
class_name Bullet

# Bullet properties
@export var speed: float = 400.0
@export var damage: int = 25
@export var lifetime: float = 2.0

# Movement - velocity property
var velocity: Vector2 = Vector2.ZERO
var lifetime_timer: float = 0.0


func _ready():
	# Configure collision:
	# - Set bullet to layer 4 (BULLETS)
	# - Set mask to detect collisions with enemies and walls
	collision_layer = PhysicsLayers.BULLETS
	collision_mask = PhysicsLayers.BULLET_MASK
	
	# Connect collision signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta):
	# Move bullet
	position += velocity * delta
	
	# Handle lifetime 
	lifetime_timer += delta
	if lifetime_timer >= lifetime: # After 2 seconds
		queue_free() # Destroy bullet even if it never hit anything


func initialize(start_position: Vector2, direction: Vector2):
	"""Initialize bullet with position and direction"""
	position = start_position
	velocity = direction.normalized() * speed

func set_velocity(new_velocity: Vector2):
	"""Set bullet velocity directly"""
	velocity = new_velocity

func get_velocity() -> Vector2:
	"""Get current bullet velocity"""
	return velocity

func _on_body_entered(body):
	"""Handle collision with StaticBody2D (walls) or CharacterBody2D (zombies)"""
	DebugManager.debug_print("combat", "Bullet hit: " + body.name)
	if body.has_method("take_damage"):
		DamageInterface.apply_damage(
			self,
			body,
			damage,
			DamageInterface.DamageType.BULLET
		)
	queue_free()

func _on_area_entered(area):
	"""Handle collision with other Area2D nodes if needed"""
	# For future use (zombie areas, triggers, etc.)
	queue_free()
