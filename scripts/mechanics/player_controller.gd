# scripts/mechanics/player_controller.gd (Autoload)
extends CharacterBody2D
class_name PlayerController

# Movement properties
@export var player_data: PlayerData
@export var speed: float = 200.0

# Bullet system
@export var bullet_scene: PackedScene
var bullet_preload: PackedScene

func _ready():
	# Initialize PlayerData if not assigned
	if not player_data:
		player_data = PlayerData.new()
		print("Created new PlayerData - Health: ", player_data.health, "/", player_data.max_health)
	
	# Sync speed with PlayerData
	speed = player_data.speed
	
	# Collision layers for player
	collision_layer = PhysicsLayers.PLAYER
	collision_mask = PhysicsLayers.PLAYER_MASK
	
	# Preload bullet scene
	bullet_preload = preload("res://scenes/gameplay/items/ammo/bullet.tscn")
	
	# Set starting position to scence position
	player_data.position = position
	
	setup_camera_limits()
	setup_camera_ui()

func _input(event):
	"""Handle all input events - mouse clicks for shooting"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			handle_shoot_input()

func _process(delta):
	# Use global debug manager for memory monitoring
	DebugManager.monitor_memory()

func _physics_process(delta):
	handle_movement()

func handle_shoot_input():
	var mouse_pos = get_global_mouse_position()
	var shoot_direction = (mouse_pos - global_position).normalized()
	shoot_bullet(shoot_direction)

func setup_camera_ui():
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "CameraUI"
	ui_layer.offset = Vector2(10, 5) # This moves the entire layer
	add_child(ui_layer)
	
	var debug_health_ui = preload("res://scenes/ui/debug_health_bar.tscn").instantiate()
	ui_layer.add_child(debug_health_ui)
	debug_health_ui.setup(player_data)


func take_damage(amount: int):
	"""Handle player taking damage with visual feedback"""
	player_data.health = max(0, player_data.health - amount)
	
	# Visual damage feedback
	modulate = Color.WHITE * 2.0 # Flash white
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	# Debug output
	print("Player took ", amount, " damage. Health: ", player_data.health, "/", player_data.max_health)
	
	# Check for death
	if player_data.health <= 0:
		die()
		
func die():
	"""Handle player death - restart scene for Day 3 consequence simulation"""
	print("Player died! Restarting scene...")
	
	# Visual death feedback
	modulate = Color.RED
	
	# FIX: Reset debug stats before scene restart
	DebugManager.reset_ai_stats()
	
	# Brief delay before restart
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func heal(amount: int):
	"""Heal player up to max health"""
	player_data.health = min(player_data.max_health, player_data.health + amount)
	print("Player healed ", amount, ". Health: ", player_data.health, "/", player_data.max_health)

func shoot_bullet(direction: Vector2):
	# Check ammo before shooting
	if not player_data.can_shoot():
		print("No ammo! Cannot shoot.")
		return
		
	if bullet_preload:
		var bullet = bullet_preload.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.initialize(global_position, direction)
		
		# Use ammo from PlayerData
		player_data.use_ammo()
		
		# Track bullet firing for debug
		DebugManager.register_bullet_fired()

func handle_movement():
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	velocity = input_vector.normalized() * speed if input_vector.length() > 0 else Vector2.ZERO
	move_and_slide()
	
	# Update PlayerData position
	player_data.position = global_position

func setup_camera_limits():
	var camera = get_node("Camera2D")
	if not camera:
		print("Camera2D not found!")
		return

	print("Camera limits set: ", camera.limit_left, ", ", camera.limit_top, " to ", camera.limit_right, ", ", camera.limit_bottom)
