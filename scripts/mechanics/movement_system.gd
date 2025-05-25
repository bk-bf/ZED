# scripts/mechanics/movement_system.gd
extends Node2D

@export var speed: float = 200.0
var velocity: Vector2 = Vector2.ZERO

func _ready():
    # Set up placeholder sprite - colored rectangle
    var sprite = ColorRect.new()
    sprite.size = Vector2(32, 32)
    sprite.color = Color.BLUE
    add_child(sprite)

func handle_input() -> Vector2:
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    return input_vector.normalized()
