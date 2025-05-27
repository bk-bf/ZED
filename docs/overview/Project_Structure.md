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
│       ├── placeholder_manager.gd
│       └── trigger_optimization.gd
├── scenes/
│   ├── base/
│   ├── core/
│   ├── debug/
│   │   └── performance_tracker.tscn
│   │   └── debug_health_bar.tscn
│   ├── gameplay/
│   │   ├── buildings/
│   │   ├── enemies/
│   │   │   └── zombie.tscn
│   │   ├── items/
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
│   │   └── bullet.gd
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
    │   ├── Core_Mechanics.md
    │   └── ROADMAP.md
    └── reports/
        ├── personal/
        │   └── Project_Overview_25.05.md
        └── public/
            ├── Progress_Report_25.05.md
            ├── Progress_Report_26.05.md
            └── Progress_Report_27.05.md
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
