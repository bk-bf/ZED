# scripts/mechanics/player_controller.gd
extends CharacterBody2D
class_name PlayerController

# Movement properties
@export var speed: float = 200.0

# Bullet system
@export var bullet_scene: PackedScene
var bullet_preload: PackedScene

func _ready():
	#Colision layers for player
	# - Set player to layer 1 (PLAYER)
	# - Set mask to detect collisions with zombies and walls
	collision_layer = PhysicsLayers.PLAYER
	collision_mask = PhysicsLayers.PLAYER_MASK
	# Preload bullet scene
	bullet_preload = preload("res://scenes/gameplay/items/ammo/bullet.tscn")
	
	# Set starting position to center of room
	position = Vector2(400, 300)
	
	# Set up camera limits automatically
	setup_camera_limits()


func _input(event):
	"""Handle all input events - mouse clicks for shooting"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			handle_shoot_input()


func _process(delta):
	# Use global debug manager for memory monitoring
	DebugManager.monitor_memory()


func handle_shoot_input():
	var mouse_pos = get_global_mouse_position()
	var shoot_direction = (mouse_pos - global_position).normalized()
	shoot_bullet(shoot_direction)


func shoot_bullet(direction: Vector2):
	if bullet_preload:
		var bullet = bullet_preload.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.initialize(global_position, direction)
		
		# Track bullet firing for debug
		DebugManager.register_bullet_fired()


func _physics_process(delta):
	handle_movement()

func handle_movement():
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	velocity = input_vector.normalized() * speed if input_vector.length() > 0 else Vector2.ZERO
	move_and_slide()

func setup_camera_limits():
	var camera = get_node("Camera2D")
	if not camera:
		print("Camera2D not found!")
		return
	
	camera.limit_left = -200
	camera.limit_right = 1000
	camera.limit_top = -200
	camera.limit_bottom = 800
	
	print("Camera limits set: ", camera.limit_left, ", ", camera.limit_top, " to ", camera.limit_right, ", ", camera.limit_bottom)
