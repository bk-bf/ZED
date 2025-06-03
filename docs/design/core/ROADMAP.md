# ZED - Development Roadmap

**Genre**: Top-down tactical looter shooter  
**Core Loop**: Clear zombie-infested buildings → Collect resources → Manage base → Repeat with increasing difficulty  
**Development Philosophy**: Playable-first development with immediate testability at every step  
**Target**: Commercial release with AI-generated assets

---

## **Project Overview**

Build immediately testable core gameplay loop

## **Phase 1: Core Mechanics (Days 1-11)**

### **Day 1: Foundation Playable Movement (2025-05-25)**
- [x] Set up project structure with clear separation (mechanics, placeholders, assets)
- [x] Configure Jolt Physics for performance optimization  
- [x] Create comprehensive placeholder asset library (colored shapes, basic sprites)
- [x] **PLAYABLE**: Create test scene with player movement (blue square moves with WASD)
- [x] **PLAYABLE**: Add basic room with walls for collision testing
- [x] **TESTABLE**: Player can walk around a simple room immediately

### **Day 2: Combat Foundation (2025-05-26)**
- [x] **PLAYABLE**: Implement shooting system (click to shoot white squares toward cursor)
- [x] **PLAYABLE**: Add 5 static zombies (red squares) in test room
- [x] **PLAYABLE**: Bullets destroy zombies on contact
- [x] **TESTABLE**: Core combat loop works - walk, aim, shoot, kill
- [x] **DOCUMENTATION**: Define primary mechanic (tactical building clearance with resource management consequences)

### **Day 3: Health Consequences (2025-05-27)**
- [x] **PLAYABLE**: Add player health system with visual health bar
- [x] **PLAYABLE**: Zombies damage player on contact
- [x] **PLAYABLE**: Death restarts the test scene (consequence simulation)
- [x] **FOUNDATION**: Implement basic damage system for all entities

### **Day 4: Resource Management (2025-05-28)**
- [x] **FOUNDATION**: ItemData class with static database methods and dictionary-based zombie loot pools
- [x] **PLAYABLE**: Dictionary-driven ammo system with ItemData integration and counter UI
- [x] **PLAYABLE**: Loot pool-configured pickups spawn from zombie death with configurable drop rates
- [x] **PLAYABLE**: ItemData-respecting collection system with stack limits and pickup feedback

### **Day 5: Simple AI Challenge (2025-05-29)**
- [x] **PLAYABLE**: Zombies chase player when in range
- [x] **PLAYABLE**: Different zombie types with different speeds/health

### **Day 6-9: Critical Bug Fix (2025-05-30 to 2025-06-02)**
- [x] **PLAYABLE**: Implement line of sight - unregistered zombies are stored in memory, not encountered zombies are invisible
- [x] **CRITICAL** Fixed game breaking *BUG-005 - Vision System Multi-Component Failure*

### **Day 10: Room Progression (2025-06-03)**
- [x] **DOCUMENTATION**: Conduct scope assessment accoring to 'docs/technical/project/Scope_Evaluation.md'
- [x] **OPTIMIZATION**: Performance optimization for 60fps with 50+ entities
- [x] **PLANNING**: Reasses current ROADMAP and update if necessary

---

## **PHASE 2: Map Content Development (Days 12-18+)**


### **Day 11: Map Design Foundation (2025-06-04)**
- [ ] **DESIGN**: Complete Level Design Document for primary map type (Hospital Complex recommended)
- [ ] **DESIGN**: Detailed map specification covering flow, ambience, loot distribution, threat placement, extraction points
- [ ] **DESIGN**: Hand-drawn sketch with player flow validation and tactical opportunity mapping
- [ ] **VALIDATION**: Playtest sketch using paper prototype or digital mockup for pacing and challenge

### **Day 12: Core Component Library (2025-06-05)**
- [ ] **FOUNDATION**: Wall system (interior, exterior, damaged variants)
- [ ] **FOUNDATION**: Door system (standard, locked, emergency, destroyed)
- [ ] **FOUNDATION**: Floor/ceiling tiles (clean, damaged, hazardous)
- [ ] **FOUNDATION**: Basic furniture (tables, chairs, beds, medical equipment)
- [ ] **TESTABLE**: All components work in test scenes with proper collision and interaction

### **Day 13: Environmental Components (2025-06-06)**
- [ ] **FOUNDATION**: Decorative elements (debris, blood, environmental storytelling)
- [ ] **FOUNDATION**: Spawn point system (zombie spawns, loot spawns, player entry/exit)
- [ ] **FOUNDATION**: Interactive elements (switches, computers, barricades)
- [ ] **FOUNDATION**: Lighting and atmosphere components
- [ ] **TESTABLE**: Component library supports varied room creation

### **Day 14: Map Assembly & Implementation (2025-06-07)**
- [ ] **PLAYABLE**: Build complete map using component library following design document
- [ ] **PLAYABLE**: Implement all spawn systems, loot distribution, and extraction points
- [ ] **PLAYABLE**: Full tactical building clearance from entry to extraction
- [ ] **TESTABLE**: Map supports intended tactical flow and challenge progression

### **Day 15: Map Polish & Validation (2025-06-08)**
- [ ] **OPTIMIZATION**: Performance optimization for full map with 50+ entities
- [ ] **PLAYABLE**: Final balancing of loot, spawns, and tactical opportunities
- [ ] **TESTABLE**: Multiple playthroughs validate replayability and tactical depth
- [ ] **DOCUMENTATION**: Component usage guide for future map development

### **Day 16: Second Map Rapid Development (2025-06-09)**
- [ ] **DESIGN**: Quick design document for second map type using established component library
- [ ] **PLAYABLE**: Rapid assembly using existing components (should take 50% less time)
- [ ] **TESTABLE**: Demonstrates component reusability and development velocity improvement
- [ ] **VALIDATION**: Two distinct tactical environments with different challenges

### **Day 17: Map System Integration (2025-06-10)**
- [ ] **PLAYABLE**: Mission selection system with multiple map options
- [ ] **PLAYABLE**: Map-specific loot tables and threat configurations
- [ ] **TESTABLE**: Full content variety supporting extended gameplay sessions
- [ ] **FOUNDATION**: Scalable map development pipeline proven and documented

### **Day 18: Mission Variety (2025-06-11)**
- [ ] **PLAYABLE**: 3 different hand-crafted building layouts (small, medium, large)
- [ ] **PLAYABLE**: Different zombie densities per mission type
- [ ] **PLAYABLE**: Mission selection screen with difficulty indicators
- [ ] **TESTABLE**: Variety in tactical challenges across designed environments
- [ ] **FOUNDATION**: Mission system with objectives and rewards

---

## **Phase 3: Content Systems (Days 19-25)**
*Expand playable content while maintaining testability*

### **Day 19: Base Management Foundation (2025-06-12)**
- [ ] **PLAYABLE**: Simple base screen with resource counters
- [ ] **PLAYABLE**: Spend collected resources on upgrades
- [ ] **PLAYABLE**: Upgrades affect next mission (more health, ammo, etc.)
- [ ] **TESTABLE**: Resource management consequences between missions
- [ ] **FOUNDATION**: Basic base building mechanics

### **Day 20: Weapon Variety (2025-06-13)**
- [ ] **PLAYABLE**: 3 weapon types (pistol, rifle, shotgun) with different stats
- [ ] **PLAYABLE**: Weapon switching during missions
- [ ] **PLAYABLE**: Weapons found as loot in hand-crafted building locations
- [ ] **TESTABLE**: Tactical weapon choice for different room layouts and situations
- [ ] **FOUNDATION**: Weapon system with stats and behaviors

### **Day 21: Advanced AI (2025-06-14)**
- [ ] **PLAYABLE**: Zombie group behavior and coordination
- [ ] **PLAYABLE**: Sound-based zombie attraction system
- [ ] **PLAYABLE**: Stealth mechanics for avoiding detection
- [ ] **TESTABLE**: Tactical depth through advanced enemy behavior
- [ ] **FOUNDATION**: AI behavior tree system

### **Day 22: Environmental Systems (2025-06-15)**
- [ ] **PLAYABLE**: Destructible environment elements
- [ ] **PLAYABLE**: Interactive objects (doors, switches, barricades)
- [ ] **PLAYABLE**: Environmental hazards and tactical elements
- [ ] **TESTABLE**: Environmental interaction affects tactical options
- [ ] **FOUNDATION**: Dynamic environment system

### **Day 23: Progression Systems (2025-06-16)**
- [ ] **PLAYABLE**: Character skill trees with meaningful upgrades
- [ ] **PLAYABLE**: Equipment modification and customization
- [ ] **PLAYABLE**: Mission rewards scale with difficulty
- [ ] **TESTABLE**: Long-term progression affects gameplay
- [ ] **FOUNDATION**: RPG-lite progression mechanics

### **Day 24: Core Content Complete (2025-06-17)**
- [ ] **PLAYABLE**: 5 distinct building types with unique challenges
- [ ] **PLAYABLE**: 10+ zombie variants with different behaviors
- [ ] **PLAYABLE**: Complete base management with multiple upgrade paths
- [ ] **TESTABLE**: Full gameplay loop with meaningful choices
- [ ] **OPTIMIZATION**: 60fps performance with complex scenarios

### **Day 25: Content Systems Integration (2025-06-18)**
- [ ] **PLAYABLE**: All systems working together seamlessly
- [ ] **TESTABLE**: Extended gameplay sessions with full feature set
- [ ] **OPTIMIZATION**: Final content system performance tuning
- [ ] **DOCUMENTATION**: Content development pipeline documentation

---

## **Phase 4: Polish & Enhancement (Days 26-32)**
*Add visual polish and expand content*

### **Day 26-27: Visual Enhancement (2025-06-19 to 2025-06-20)**
- [ ] **VISUAL**: Replace placeholder art with AI-generated assets
- [ ] **VISUAL**: Particle effects for combat and environmental interactions
- [ ] **VISUAL**: Lighting system for atmosphere and tactical gameplay
- [ ] **FOUNDATION**: Asset pipeline for AI-generated content

### **Day 28-29: Audio Implementation (2025-06-21 to 2025-06-22)**
- [ ] **AUDIO**: Sound effects for all game actions
- [ ] **AUDIO**: Ambient audio for different environments
- [ ] **AUDIO**: Music system with dynamic tracks
- [ ] **FOUNDATION**: Audio management system

### **Day 30-31: UI/UX Polish (2025-06-23 to 2025-06-24)**
- [ ] **UI**: Professional interface design
- [ ] **UI**: Tutorial system for new players
- [ ] **UI**: Settings and options menus
- [ ] **FOUNDATION**: Comprehensive UI framework

### **Day 32: Pre-Launch Prep (2025-06-25)**
- [ ] **TESTING**: Comprehensive bug testing and fixes
- [ ] **OPTIMIZATION**: Final performance optimization
- [ ] **DOCUMENTATION**: Player-facing documentation
- [ ] **RELEASE**: Build preparation and distribution setup

---

## **Success Metrics**
- [ ] **Day 18**: Core gameplay loop is fun and engaging
- [ ] **Day 25**: 2+ hours of varied gameplay content
- [ ] **Day 32**: Release-ready game with professional presentation

## **Risk Mitigation**
- Each day produces immediately testable content
- Critical systems implemented early in development
- Placeholder assets allow focus on mechanics
- Modular design enables feature iteration
