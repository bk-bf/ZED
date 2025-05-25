extends Node
class_name PhysicsLayers

# Collision layers (what objects are on)
const PLAYER = 1
const ENEMIES = 2
const PROJECTILES = 4
const WALLS = 8
const LOOT = 16
const TRIGGERS = 32

# Collision masks (what objects detect)
const PLAYER_MASK = ENEMIES | WALLS | LOOT | TRIGGERS
const ENEMY_MASK = PLAYER | WALLS | PROJECTILES
const PROJECTILE_MASK = PLAYER | ENEMIES | WALLS
const LOOT_MASK = PLAYER
