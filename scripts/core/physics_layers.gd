# scripts/core/physics_layers.gd
class_name PhysicsLayers

# Define collision layer constants
const PLAYER = 1 # Binary: 0001
const ENEMIES = 2 # Binary: 0010
const BULLETS = 4 # Binary: 0100
const WALLS = 8 # Binary: 1000
const PICKUPS = 16 # Binary: 10000

# Collision mask combinations
const PLAYER_MASK = ENEMIES | WALLS | PICKUPS # Player collides with enemies, walls, pickups
const BULLET_MASK = ENEMIES | WALLS # Bullets collide with enemies and walls
const ENEMY_MASK = PLAYER | WALLS | BULLETS # Enemies collide with player, walls, bullets
