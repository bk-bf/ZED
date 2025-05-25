# Apocalypse Clearance Project Structure

## Directory Layout

```
apocalypse_clearance/
├── project.godot
├── scenes/
│   ├── core/
│   │   ├── game_manager.tscn
│   │   ├── mission_manager.tscn
│   │   └── base_manager.tscn
│   ├── gameplay/
│   │   ├── player/
│   │   │   ├── player.tscn
│   │   │   └── player_controller.gd
│   │   ├── enemies/
│   │   │   ├── zombie_basic.tscn
│   │   │   └── enemy_ai.gd
│   │   ├── buildings/
│   │   │   ├── room_template.tscn
│   │   │   └── building_generator.gd
│   │   └── weapons/
│   │       ├── weapon_base.tscn
│   │       └── projectile.tscn
│   ├── ui/
│   │   ├── main_menu.tscn
│   │   ├── mission_select.tscn
│   │   ├── inventory.tscn
│   │   └── hud.tscn
│   └── base/
│       ├── base_overview.tscn
│       └── survivor_management.tscn
├── scripts/
│   ├── core/
│   │   ├── game_manager.gd
│   │   ├── event_bus.gd
│   │   └── constants.gd
│   ├── mechanics/
│   │   ├── movement_system.gd
│   │   ├── combat_system.gd
│   │   ├── inventory_system.gd
│   │   ├── health_system.gd
│   │   └── resource_manager.gd
│   ├── systems/
│   │   ├── placeholder_manager.gd
│   │   ├── mission_system.gd
│   │   ├── procedural_generation.gd
│   │   ├── save_system.gd
│   │   └── audio_manager.gd
│   └── data/
│       ├── weapon_data.gd
│       ├── enemy_data.gd
│       └── mission_data.gd
├── assets/
│   ├── placeholders/
│   │   ├── sprites/
│   │   │   ├── player_placeholder.png (colored rectangle)
│   │   │   ├── zombie_placeholder.png (colored circle)
│   │   │   ├── weapon_placeholders/
│   │   │   └── ui_placeholders/
│   │   ├── audio/
│   │   │   ├── sfx_placeholders/
│   │   │   └── music_placeholders/
│   │   └── materials/
│   │       ├── floor_tiles/
│   │       ├── wall_tiles/
│   │       └── ui_materials/
│   ├── generated/ (for AI assets later)
│   │   ├── characters/
│   │   ├── weapons/
│   │   ├── environments/
│   │   └── ui/
│   └── final/ (production-ready assets)
├── data/
│   ├── missions/
│   ├── buildings/
│   └── configs/
└── docs/
	├── mechanics_documentation.md
	├── asset_specifications.md
	└── development_notes.md
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
