# scripts/mechanics/player_controller.gd
extends CharacterBody2D
class_name PlayerController

# Movement properties
@export var speed: float = 200.0

func _ready():
    # Visual is already set up in the scene tree
    # No need to create ColorRect programmatically
    pass

func _physics_process(delta):
    handle_movement()

func handle_movement():
    # Get input vector from WASD keys (via Input Map)
    var input_vector = Vector2.ZERO
    
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    
    # Normalize diagonal movement and apply speed
    velocity = input_vector.normalized() * speed if input_vector.length() > 0 else Vector2.ZERO
    
    # Apply movement
    move_and_slide()
