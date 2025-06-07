# ZED - Core Mechanics Documentation

ZED is a top-down arcade looter shooter inspired by Synthetik and Borderlands, set in a post-apocalyptic world. Players deploy to procedurally generated houses for quick extraction runs, collecting color-coded loot and battling zombie hordes in fast-paced 5-10 minute sessions with infinite replayability.

## Core Game Loop

### 1. House Selection Phase
- **Level Selection**: Choose house difficulty (1-10) affecting size, zombie density, and loot tier chances
- **Loadout Preparation**: Equip best available weapons and medical supplies from previous runs
- **Risk Assessment**: Higher house levels offer better loot tiers but increased danger

### 2. House Clearing Phase
- **Deployment**: Enter procedurally generated house layouts (5-15 rooms based on level)
- **Room-by-Room Clearing**: Eliminate zombies using tactical positioning and weapon variety
- **Loot Collection**: Gather color-coded items with procedural stats and tier-based rarity
- **Resource Management**: Balance ammunition consumption against zombie threats
- **Extraction**: Exit house to secure all collected loot and progression

### 3. Progression Phase
- **Loot Evaluation**: Compare new weapons and items against current loadout
- **Weapon Upgrades**: Replace equipment with higher-tier procedural variants
- **House Level Progression**: Unlock access to higher difficulty houses with better rewards

## Loot Tier System

### Color-Coded Rarity Hierarchy
- **Gray**: Damaged/broken items (vendor trash)
- **White**: Common civilian equipment (baseline stats)
- **Green**: Uncommon military surplus (improved stats)
- **Blue**: Rare police/security gear (significant upgrades)
- **Purple**: Epic special forces equipment (major improvements)
- **Orange**: Legendary prototype weapons (maximum performance)

### Procedural Weapon Generation
Each weapon type (pistol, rifle, shotgun, medical pack) generates with randomized stats:
- **Damage**: Base damage modified by tier multiplier and house level
- **Accuracy**: Precision rating affecting hit chance and spread
- **Fire Rate**: Shots per second determining DPS potential
- **Ammo Capacity**: Magazine size affecting sustained combat capability
- **Special Properties**: Tier-specific bonuses (critical chance, armor penetration, etc.)

### Loot Distribution Logic
- **House Level Scaling**: Higher levels increase chances of better tier drops
- **Room-Specific Spawns**: Logical placement (weapons in bedrooms, medical in bathrooms)
- **Zombie Tier Drops**: Stronger zombie variants drop better loot tiers
- **Extraction Rewards**: Bonus loot for successful house completion

## Procedural House Generation

### Room Type System
Houses generate with 5-15 rooms depending on difficulty level:
- **Living Room**: Electronics, civilian weapons, furniture cover
- **Kitchen**: Food, medical supplies, improvised weapons
- **Bedroom**: Personal items, ammunition, weapon spawns
- **Bathroom**: Medical supplies, cleaning chemicals
- **Entrance**: Central hub connecting other rooms
- **Storage**: Rare items, tool spawns, bonus loot

### House Scaling Mechanics
- **Level 1-3**: Small houses (5-7 rooms), mostly Gray/White loot, basic zombies
- **Level 4-6**: Medium houses (8-10 rooms), Green/Blue loot chances, mixed zombie types
- **Level 7-10**: Large houses (12-15 rooms), Purple/Orange possibilities, elite zombie variants

### Tactical Layout Features
- **Room Merging**: Kitchen + living room combinations for varied layouts
- **Alternative Entries**: Destroyed walls, locked doors requiring keys
- **Furniture Placement**: Cover objects and tactical positioning opportunities
- **Extraction Points**: Multiple exit options (front door, back door, windows)

## Combat and Zombie System

### Zombie Variety (5 Types)
- **Walker**: Slow, high health, basic threat (common in all house levels)
- **Runner**: Fast, medium health, flanking behavior (appears level 3+)
- **Brute**: Slow, very high health, heavy damage (appears level 5+)
- **Crawler**: Low profile, surprise attacks, fast movement (appears level 4+)
- **Spitter**: Ranged attacks, medium health, area denial (appears level 6+)

### Zombie Scaling
- **Density**: More zombies per room at higher house levels
- **Type Distribution**: Higher levels feature more dangerous variants
- **Behavior**: Room-specific AI (sleeping in bedrooms, feeding in kitchen)
- **Stats**: Health and damage scale with house level progression

### Weapon Types and Roles
- **Pistol**: High accuracy, low damage, efficient ammo usage
- **Rifle**: Balanced damage and accuracy, versatile engagement range
- **Shotgun**: High damage, close range, crowd control capability
- **Medical Pack**: Healing items, damage resistance, survival utility

## Arcade Shooter Mechanics

### Session Structure
- **Quick Deployment**: Immediate house entry without complex preparation
- **Fast-Paced Combat**: Responsive shooting with satisfying weapon feedback
- **Clear Objectives**: Eliminate all zombies, collect loot, extract safely
- **Immediate Rewards**: Instant loot comparison and progression feedback

### Infinite Replayability
- **Procedural Generation**: Every house layout is unique and unpredictable
- **Loot Variety**: Infinite weapon combinations through procedural stats
- **Difficulty Scaling**: Always higher house levels to challenge improved equipment
- **Optimization Goals**: Perfect stat combinations and legendary weapon hunting

### Risk/Reward Balance
- **House Level Choice**: Players select their preferred risk/reward ratio
- **Loot vs. Safety**: Push deeper for better items or extract early with guaranteed gains
- **Ammunition Management**: Limited resources force tactical engagement decisions
- **Equipment Progression**: Better gear enables tackling higher difficulty houses

## Progression Systems

### House Level Progression
- **Unlock System**: Success at current level unlocks next difficulty tier
- **Scaling Rewards**: Higher levels offer exponentially better loot chances
- **Challenge Scaling**: Zombie density and variety increase with house level
- **Mastery Goals**: Perfect clears and speed run achievements

### Weapon Collection
- **Tier Hunting**: Seeking higher-tier versions of preferred weapon types
- **Stat Optimization**: Finding perfect combinations of damage, accuracy, and fire rate
- **Build Diversity**: Different weapon stats enable varied playstyles
- **Collection Goals**: Acquiring legendary weapons in each category

### Achievement Integration
- **Loot Milestones**: First Purple weapon, first Orange weapon, perfect stat rolls
- **Combat Achievements**: Headshot streaks, perfect accuracy runs, speed clears
- **House Mastery**: Completing all difficulty levels, rare house variants
- **Collection Completionist**: Acquiring weapons of each tier in every category

## Success Metrics

### Session Success
- **House Completion**: All zombies eliminated and successful extraction
- **Loot Quality**: Higher-tier items collected compared to previous runs
- **Efficiency**: Ammunition conservation and minimal health loss
- **Time Performance**: Quick clears enabling more runs per play session

### Long-term Progression
- **Equipment Improvement**: Steady upgrade path through loot tier progression
- **House Level Advancement**: Access to increasingly challenging and rewarding content
- **Mastery Development**: Improved tactical skills and weapon handling
- **Collection Growth**: Expanding arsenal of high-tier weapons and equipment

---

This document defines the core mechanics that drive player engagement through immediate action, meaningful loot progression, infinite procedural variety, and satisfying arcade shooter gameplay with extraction shooter risk/reward elements.
