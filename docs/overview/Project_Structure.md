# 🧟‍♂️ ZED - Zombie Extraction Deliverance Project Structure

## Directory Layout

```
top_down_apocalypse_looter_shoter/
├── project.godot
├── icon.svg
├── icon.svg.import
├── README.md
├── scenes/
│   ├── core/
│   ├── base/
│   ├── ui/
│   └── gameplay/
│       ├── player/
│       ├── enemies/
│       ├── buildings/
│       └── items/
├── scripts/
│   ├── core/
│   │   ├── game_manager.gd
│   │   └── physics_layers.gd
│   ├── data/
│   │   ├── loot_data.gd
│   │   ├── player_data.gd
│   │   ├── projectile_data.gd
│   │   └── zombie_data.gd
│   ├── debug/
│   │   ├── performance_tracker.gd
│   │   └── physics_monitor.gd
│   ├── mechanics/
│   │   ├── movement_system.gd
│   │   ├── physics_optimization.gd
│   │   └── trigger_optimization.gd
│   └── systems/
│       ├── collision_manager.gd
│       ├── entity_manager.gd
│       ├── jolt_config.gd
│       ├── physics_config.gd
│       └── placeholder_manager.gd
├── assets/
│   ├── placeholders/
│   │   ├── sprites/
│   │   ├── audio/
│   │   └── materials/
│   ├── generated/
│   └── final/
├── data/
│   ├── buildings/
│   ├── configs/
│   │   └── weapon_config.gd
│   └── missions/
└── docs/
    ├── Project_Structure.md
    └── ROADMAP.md
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
