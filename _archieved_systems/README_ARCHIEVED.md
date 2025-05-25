# Archived Systems - ZED Development

## Why These Were Archived
These systems were created during the "shadow development" phase before pivoting to playable-first development. They may contain useful code but are not connected to the current working systems.

## When to Rebuild Archived Systems

### Day 3: Simple Data Classes
- Rebuild PlayerData with only: health, position, ammo
- Rebuild ZombieData with only: health, position, is_alive

### Day 5: Physics Layers  
- Use existing physics_layers.gd as reference
- Add layers for: PLAYER, ZOMBIES, BULLETS, WALLS

### Day 6+: Performance Config
- Rebuild jolt_config.gd when spawning 20+ zombies
- Focus only on performance settings you understand

### Day 8+: Game Management
- Rebuild game_manager.gd for mission systems
- Start simple: mission_start(), mission_complete()

- **Day 5+**: Entity manager may be useful for zombie spawning
- **Day 12+**: Placeholder manager may be useful for AI asset pipeline
- **Performance Issues**: Physics optimization scripts may be needed

## Integration Notes
If reintegrating these systems:
1. Check for code duplication with current working systems
2. Ensure they work with current scene structure
3. Test immediately after integration
