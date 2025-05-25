# scripts/mechanics/player_controller.gd
extends CharacterBody2D
class_name PlayerController

# Movement properties
@export var speed: float = 200.0

func _ready():
    # Set starting position to center of room
    position = Vector2(400, 300)
    
    # Set up camera limits automatically
    setup_camera_limits()

func setup_camera_limits():
    var camera = get_node("Camera2D")
    if not camera:
        print("Camera2D not found!")
        return
    
    # Set wider limits - camera can see beyond walls but won't show empty space
    camera.limit_left = -200 # Allow camera to show some area beyond left wall
    camera.limit_right = 1000 # Allow camera to show some area beyond right wall
    camera.limit_top = -200 # Allow camera to show some area beyond top wall
    camera.limit_bottom = 800 # Allow camera to show some area beyond bottom wall
    
    print("Camera limits set: ", camera.limit_left, ", ", camera.limit_top, " to ", camera.limit_right, ", ", camera.limit_bottom)


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
