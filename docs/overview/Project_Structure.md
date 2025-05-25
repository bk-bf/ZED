# 🧟‍♂️ ZED - Project Structure

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
│       └── trigger_optimization.gd
├── scenes/
│   ├── base/
│   ├── core/
│   ├── debug/
│   │   └── performance_tracker.tscn
│   ├── gameplay/
│   │   ├── buildings/
│   │   ├── enemies/
│   │   ├── items/
│   │   └── player/
│   ├── testing/
│   │   ├── horizontal_wall.tscn
│   │   ├── movement_test.tscn
│   │   ├── player.tscn
│   │   └── vertical_wall.tscn
│   └── ui/
├── scripts/
│   ├── core/
│   │   ├── jolt_config.gd
│   │   └── physics_layers.gd
│   ├── debug/
│   │   ├── performance_tracker.gd
│   │   └── physics_monitor.gd
│   ├── mechanics/
│   │   └── player_controller.gd
│   └── systems/
├── assets/
│   ├── final/
│   ├── generated/
│   └── placeholders/
│       ├── audio/
│       ├── materials/
│       └── sprites/
├── data/
│   ├── buildings/
│   ├── configs/
│   └── missions/
└── docs/
    ├── overview/
    │   ├── DAILY_TASKS.md
    │   ├── Project_Structure.md
    │   └── ROADMAP.md
    └── reports/
        ├── personal/
        │   └── Project_Overview_25.05.md
        └── public/
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
