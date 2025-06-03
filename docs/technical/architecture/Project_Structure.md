# 🧟‍♂️ ZED - Project Structure

# Technical Architecture & Optimization

## Core System Architecture

### EntityManager Pattern
- **Centralized Entity Control**: Single point for spawning, updating, and destroying all game entities
- **Performance Monitoring**: Built-in entity counting and memory tracking for 50+ entity target
- **Lifecycle Management**: Automatic cleanup and pooling for zombies, loot, and projectiles

### Component-Based Design
- **DamageInterface**: Unified damage handling across all entities (players, zombies, destructibles)
- **Signal-Based Communication**: Decoupled UI updates and system interactions
- **Modular Systems**: ItemData, InventoryManager, and ResourceManager as independent components

### Data Management
- **Singleton Pattern**: Global access to ItemDatabase, GameSettings, and ProgressTracker
- **Persistent Storage**: JSON-based save system for base upgrades and unlocked locations
- **Memory Efficiency**: Static typing throughout for GDScript optimization

## Performance Optimization Strategies

### Planned Optimizations (From Roadmap)

#### Entity Management
- **Object Pooling**: Reuse zombie and projectile instances instead of constant instantiation[1]
- **Spatial Partitioning**: Grid-based entity tracking for efficient collision detection
- **Update Frequency Scaling**: Reduce AI update rates for distant or off-screen zombies[2]

#### Rendering Optimization
- **Visibility Culling**: Use VisibilityNotifier2D nodes for off-screen entity deactivation[2]
- **Sprite Batching**: Group similar sprites to reduce draw calls
- **LOD System**: Simplified zombie sprites at distance for large horde scenarios

### Additional Optimization Techniques

#### CPU Optimization for Top-Down Zombie Shooter

**AI Pathfinding Efficiency**
- **Shared Pathfinding**: Group nearby zombies to share navigation calculations[2]
- **Staggered Updates**: Spread AI calculations across multiple frames to prevent spikes
- **Distance-Based AI**: Reduce pathfinding complexity for zombies beyond player interaction range[7]

**Physics Optimization**
- **Collision Layer Optimization**: Separate collision layers for bullets, zombies, environment, and loot
- **Area2D for Triggers**: Use Area2D instead of RigidBody2D for loot collection and extraction zones
- **Static Body Caching**: Pre-calculate collision shapes for building layouts

**Memory Management**
- **Texture Streaming**: Load building textures on-demand as players approach new areas
- **Audio Pooling**: Reuse AudioStreamPlayer nodes for gunshots and zombie sounds
- **Garbage Collection Awareness**: Minimize object creation during combat sequences

#### GPU Optimization for Extraction Shooter

**Rendering Pipeline**
- **Sprite Atlasing**: Combine zombie, weapon, and UI sprites into texture atlases
- **Shader Optimization**: Use simple shaders for blood effects and muzzle flashes
- **Particle System Efficiency**: Limit particle count for bullet impacts and explosions

**Lighting and Effects**
- **Baked Lighting**: Pre-calculate lighting for building interiors[2]
- **Dynamic Light Limits**: Restrict flashlight and muzzle flash light count
- **Effect Culling**: Disable visual effects outside camera view

#### Extraction Shooter Specific Optimizations

**Large Building Performance**
- **Room-Based Loading**: Stream building sections as players move through areas
- **Occlusion Culling**: Use walls and doors to hide non-visible areas[9]
- **Entity Streaming**: Spawn/despawn zombies based on player proximity

**Inventory and Loot Optimization**
- **UI Pooling**: Reuse inventory slot UI elements instead of creating new ones
- **Batch Loot Updates**: Update multiple loot spawns simultaneously rather than individually
- **Texture Compression**: Compress item icons and UI elements for memory efficiency

**Combat System Performance**
- **Bullet Pooling**: Reuse projectile objects for high-rate-of-fire weapons
- **Hit Detection Optimization**: Use Area2D overlap detection instead of continuous raycasting
- **Audio Mixing**: Limit simultaneous gunshot sounds to prevent audio bottlenecks

## Scalability Patterns

### Horizontal Scaling
- **Modular Building System**: Each building type can be independently optimized
- **Component Expansion**: New entity types inherit from existing DamageInterface
- **Save System Scaling**: JSON structure supports unlimited base upgrades and unlocks

### Performance Monitoring
- **Real-Time Metrics**: FPS counter, entity count, and memory usage display[4]
- **Performance Budgets**: Target 60fps with 50+ entities as baseline requirement
- **Bottleneck Detection**: Built-in profiling for AI, rendering, and physics systems

### Adaptive Quality Settings
- **Dynamic LOD**: Automatic sprite detail reduction based on performance[4]
- **Effect Scaling**: Reduce particle density and lighting quality on lower-end hardware
- **AI Complexity Scaling**: Fewer zombie behaviors when performance drops

## Platform-Specific Considerations

### Desktop Optimization
- **Multi-Threading**: Use background threads for pathfinding and file I/O operations[6]
- **High Entity Counts**: Support for 100+ zombies in large building scenarios
- **Advanced Effects**: Full particle systems and dynamic lighting

## Debug and Profiling Integration

### Development Tools
- **DebugManager Integration**: Real-time performance metrics overlay
- **Entity Visualization**: Debug drawing for collision shapes and AI states
- **Performance Graphs**: Frame time tracking and bottleneck identification

### Production Monitoring
- **Crash Reporting**: Automatic error logging for post-release optimization
- **Performance Analytics**: Player hardware profiling for optimization priorities
- **Memory Leak Detection**: Automated testing for entity cleanup verification

## Implementation Priority

### Phase 1 (Days 5-12): Core Optimization
- Object pooling for zombies and projectiles
- Basic visibility culling implementation
- Static typing completion across all systems

### Phase 2 (Days 13-20): Advanced Performance
- AI pathfinding optimization and grouping
- Sprite batching and texture atlasing
- Room-based entity streaming

### Phase 3 (Days 21-28): Polish and Scaling
- Adaptive quality settings implementation
- Performance monitoring UI
- Platform-specific optimizations

---

This technical architecture ensures your extraction shooter maintains 60fps performance while supporting the tactical complexity and entity density required for compelling zombie encounters in large building environments.


## Directory Layout

```
ZED/
├── project.godot
├── icon.svg
├── icon.svg.import
├── README.md
├── .editorconfig
├── .gitattributes
├── .gitignore
├── .godot/
│   ├── editor/
│   │   ├── editor_layout.cfg
│   │   ├── filesystem_cache10
│   │   ├── filesystem_update4
│   │   └── [other editor files]
│   └── [other Godot cache files]
├── .vscode/
│   ├── launch.json
│   └── settings.json
├── _archieved_systems/
│   ├── README_ARCHIEVED.md
│   ├── unused_mechanics/
│   │   ├── loot_data.gd
│   │   ├── player_data.gd
│   │   ├── projectile_data.gd
│   │   ├── weapon_config.gd
│   │   └── zombie_data.gd
│   └── unused_systems/
│       ├── entity_manager.gd
│       ├── placeholder_manager.gd
│       └── trigger_optimization.gd
├── scenes/
│   ├── base/
│   ├── core/
│   ├── debug/
│   │   ├── performance_tracker.tscn
│   │   └── debug_health_bar.tscn
│   ├── gameplay/
│   │   ├── buildings/
│   │   ├── enemies/
│   │   │   └── zombie.tscn
│   │   ├── items/
│   │   │   ├── ammo/
│   │   │   │   └── bullet.tscn
│   │   │   └── item_pickup.tscn
│   │   ├── player/
│   │   └── projectiles/
│   │       └── bullet.tscn
│   ├── testing/
│   │   ├── horizontal_wall.tscn
│   │   ├── movement_test.tscn
│   │   ├── combat_test.tscn
│   │   ├── player.tscn
│   │   └── vertical_wall.tscn
│   └── ui/
│       ├── debug_health_bar.tscn
│       ├── debug_ammo_counter.tscn
│       └── health_bar.tscn
├── scripts/
│   ├── core/
│   │   ├── jolt_config.gd
│   │   ├── physics_layers.gd
│   │   └── debug_manager.gd
│   ├── debug/
│   │   ├── performance_tracker.gd
│   │   ├── physics_monitor.gd
│   │   └── debug_health_bar.gd
│   ├── entities/
│   │   ├── player_data.gd
│   │   └── zombie_data.gd
│   ├── interfaces/
│   │   └── damage_interface.gd
│   ├── mechanics/
│   │   ├── player_controller.gd
│   │   ├── zombie.gd
│   │   ├── bullet.gd
│   │   └── item_pickup.gd
│   └── systems/
├── assets/
│   ├── final/
│   ├── fonts/
│   │   └── Roboto_Condensed/
│   │       └── RobotoCondensed-ExtraBold.ttf
│   ├── generated/
│   └── placeholders/
│       ├── audio/
│       ├── materials/
│       └── sprites/
├── data/
│   ├── buildings/
│   ├── configs/
│   ├── items/
│   └── missions/
└── docs/
    ├── overview/
    │   ├── BUG_TRACKER.md
    │   ├── Core_Mechanics.md
    │   ├── DAILY_TASKS.md
    │   ├── Project_Structure.md
    │   └── ROADMAP.md
    └── reports/
        ├── personal/
        │   └── Project_Overview_(intern_doc)25.05.md
        └── public/
            ├── Progress_Report_25.05.md
            ├── Progress_Report_26.05.md
            ├── Progress_Report_27.05.md
            └── Progress_Report_28.05.md
```

## Asset Naming Convention

### Sprites
Format: `[category]_[type]_[variant]_[size].png`

Examples:
- `char_player_default_32.png`
- `weap_pistol_glock_16.png`
- `env_wall_concrete_32.png`

### Audio
Format: `[category]_[action]_[variant].ogg`

Examples:
- `sfx_gunshot_pistol_01.ogg`
- `amb_building_creepy_loop.ogg`
