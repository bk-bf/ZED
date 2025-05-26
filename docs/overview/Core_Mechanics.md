# ZED - Core Mechanics Documentation

## Overview
ZED is a top-down tactical extraction shooter inspired by Escape from Tarkov and Stalker Anomaly, set in a post-apocalyptic world. Players lead survivors through dangerous missions to collect resources, complete objectives, and extract safely while managing permanent consequences for failure.

## Core Game Loop

### 1. Mission Planning Phase
- **Base Operations**: Interact with workbenches, storage, and facilities in your base room
- **Quest Selection**: Choose from available missions with varying objectives and difficulty
- **Location Selection**: Pick from unlocked buildings on the world map
- **Loadout Preparation**: Equip weapons, medical supplies, and gear before deployment

### 2. Mission Execution Phase
- **Deployment**: Get dropped into procedurally arranged building layouts
- **Objective Completion**: Fulfill quest requirements (rescue, elimination, retrieval)
- **Resource Collection**: Gather loot while managing inventory space and weight
- **Threat Management**: Combat zombies, mutants, bandits, and environmental hazards
- **Extraction**: Reach randomized extraction points to secure progress

### 3. Base Development Phase
- **Loot Processing**: Sort and store collected resources
- **Base Upgrades**: Build and upgrade workbenches for crafting and production
- **Progression**: Unlock new locations, quests, and capabilities

## Death and Consequence System

### Difficulty-Based Death Mechanics

#### Standard Difficulty (Default)
- **Player Character**: Death results in losing ALL carried equipment and loot
- **Recovery Process**: Player wakes up injured at base, requires medical resources for treatment
- **Gear Loss**: Must re-equip and restock before next mission
- **Progress Impact**: Setback due to lost equipment and medical costs
- **Character Persistence**: Player character survives but suffers consequences

#### Permadeath Difficulty (Optional)
- **True Death**: Character death is permanent and irreversible
- **Survivor System**: Recruited NPCs can continue the mission/campaign
- **Character Switching**: Can deploy either main character or recruited survivors
- **Game Over Conditions**: 
  - All characters dead = campaign failure
  - Main character dead with no survivors = immediate game over
- **Strategic Depth**: Forces careful survivor recruitment and risk management

### Character Management System

#### Main Character
- **Standard Mode**: Respawns at base with gear loss and injury
- **Permadeath Mode**: Permanent death if killed
- **Base Operations**: Can manage base, plan missions, and lead expeditions

#### Recruited Survivors
- **Both Difficulties**: Permanent death when killed in missions
- **Mission Deployment**: Can be sent on missions instead of main character
- **Specialized Skills**: Each survivor may have unique abilities or bonuses
- **Backup Leadership**: Can continue campaign if main character dies (Permadeath mode)

### Risk Mitigation Strategies

#### Standard Difficulty
- **Medical Preparation**: Stock healing items before dangerous missions
- **Gear Insurance**: Keep backup equipment at base
- **Early Extraction**: Retreat when health is low to preserve character
- **Resource Buffer**: Maintain medical supplies for post-mission recovery

#### Permadeath Difficulty
- **Survivor Recruitment**: Priority on finding and recruiting capable NPCs
- **Character Rotation**: Use different characters for different mission types
- **Emergency Protocols**: Always have extraction plans and backup characters
- **Conservative Play**: Higher emphasis on tactical positioning and risk assessment

### Base Persistence (All Difficulties)
- **Facility Upgrades**: Base improvements remain regardless of character deaths
- **Stored Resources**: Stockpiled supplies stay safe at base
- **Knowledge Retention**: Unlocked locations and completed quests persist
- **Technology Progress**: Research and crafting unlocks carry forward

### Mission Consequences

#### Failed Extraction (Standard)
- **Gear Loss**: All carried equipment lost
- **Medical Costs**: Resources required for character recovery
- **Time Loss**: Recovery period before next mission
- **Morale Impact**: Potential negative effects on base operations

#### Failed Extraction (Permadeath)
- **Character Death**: Permanent loss of deployed character
- **Survivor Impact**: Remaining characters may suffer morale penalties
- **Strategic Reassessment**: May need to recruit new team members
- **Campaign Continuation**: Switch to surviving character or face game over


## Resource and Loot System

### Loot Categories
- **Ammunition**: Various calibers for different weapon types
- **Medical Supplies**: Bandages, painkillers, antibiotics, surgical kits
- **Consumables**: Food, water, energy drinks for sustenance and buffs
- **Electronics**: Components for base upgrades and quest objectives
- **Tools and Materials**: Crafting components and repair supplies
- **Weapons and Gear**: Firearms, melee weapons, armor, and equipment

### Location-Specific Loot
- **Electronics Market**: Computer parts, batteries, advanced components
- **Steel Mill**: Tools, raw materials, industrial equipment
- **Hospital**: Medical supplies, pharmaceuticals, surgical equipment
- **Residential**: Food, basic supplies, personal items
- **Military**: Weapons, ammunition, tactical gear

## Quest and Objective System

### Mission Types
- **Rescue Operations**: Locate and extract survivors (potential recruits)
- **Elimination Contracts**: Neutralize specific threats (bosses, bandit leaders)
- **Retrieval Missions**: Secure specific items or intelligence
- **Clearance Operations**: Eliminate all threats in designated areas
- **Supply Runs**: Collect specific resource quotas

### Objective Scaling
- **Difficulty Progression**: Harder missions unlock as base capabilities improve
- **Dynamic Threats**: Enemy types and densities scale with player progression
- **Reward Scaling**: Better loot and resources in more dangerous locations

## Base Building and Progression

### Base Facilities
- **Storage Systems**: Secure containers for loot and equipment
- **Medical Bay**: Treatment facilities and medicine production
- **Workshop**: Weapon modification and equipment crafting
- **Communications**: Quest management and survivor coordination
- **Power Generation**: Energy systems for advanced facilities

### Progression Gates
- **Technology Unlocks**: New crafting recipes and base modules
- **Location Access**: Unlock new buildings and districts
- **Quest Availability**: Advanced missions require base development
- **Survivor Integration**: Rescued NPCs provide specialized skills

## Tactical Combat System

### Engagement Principles
- **Positioning**: Cover, line of sight, and environmental advantages
- **Resource Conservation**: Limited ammunition forces tactical thinking
- **Threat Assessment**: Different enemies require different approaches
- **Escape Options**: Sometimes retreat is the optimal strategy

### Enemy Types
- **Zombies**: Slow but numerous, attracted to noise
- **Mutants**: Fast and dangerous, unique abilities
- **Bandits**: Intelligent opponents with weapons and tactics
- **Bosses**: Unique encounters requiring specific strategies

## Risk/Reward Balance

### High-Risk Areas
- **Better Loot**: Dangerous zones contain superior resources
- **Rare Materials**: Unique components only found in hazardous locations
- **Quest Objectives**: Important targets often in heavily defended areas

### Risk Mitigation Strategies
- **Preparation**: Better equipment and supplies improve survival odds
- **Knowledge**: Learning enemy patterns and location layouts
- **Timing**: Choosing when to push forward vs. when to extract
- **Resource Management**: Balancing current needs vs. future preparation

## Procedural Generation System

### Building Layouts
- **Template Variations**: 3-4 different layouts per building type
- **Dynamic Arrangement**: Room connections and enemy placement vary
- **Thematic Consistency**: Loot and threats match location type
- **Extraction Randomization**: Exit points change each mission

### Progression Integration
- **Unlocked Content**: New building types become available over time
- **Difficulty Scaling**: Enemy density and types increase with progression
- **Reward Scaling**: Better loot becomes available in advanced areas

## Success Metrics

### Mission Success
- **Objective Completion**: Primary goals fulfilled
- **Successful Extraction**: Player reaches extraction point alive
- **Loot Secured**: Collected resources added to base storage
- **Progression**: Experience and unlocks gained

### Long-term Success
- **Base Development**: Facilities upgraded and expanded
- **Territory Control**: More locations unlocked and accessible
- **Survivor Network**: Rescued NPCs providing ongoing benefits
- **Equipment Superiority**: Better gear enabling harder missions

---

*This document defines the core mechanics that drive player engagement through meaningful risk/reward decisions and permanent progression consequences.*
