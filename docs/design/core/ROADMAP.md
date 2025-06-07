# ZED - Development Roadmap

**Genre**: Top-down arcade extraction shooter  
**Core Loop**: Deploy to house → Clear rooms and loot → Extract → Repeat with increasing difficulty  
**Development Philosophy**: Playable-first development with immediate testability at every step  
**Target**: Commercial release with AI-generated assets

---

## **Project Overview**

Build immediately testable core gameplay loop with procedural house generation for infinite replayability

## **Phase 1: Core Mechanics (Days 1-11) - COMPLETE**

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
- [x] **PLAYABLE**: Implement line of sight - unregistered zombies are stored in memory, not encountered zombies are invisible
- [x] **TESTABLE**: Tactical positioning and kiting mechanics

### **Day 6-9: Critical Bug Fix (2025-05-30 to 2025-06-02)**
- [x] **CRITICAL**: Fixed game breaking *BUG-005 - Vision System Multi-Component Failure*
- [x] **CRITICAL**: Fixed *BUG-007 - Respawn Performance Breakdown* with deferred scene loading

### **Day 10: Performance Validation (2025-06-03)**
- [x] **DOCUMENTATION**: Conduct scope assessment according to 'docs/technical/project/Scope_Evaluation.md'
- [x] **OPTIMIZATION**: Performance optimization for 60fps with 50+ entities
- [x] **PLANNING**: Reassess current ROADMAP and update direction

---

## **Phase 2: Procedural House Generation (Days 12-18)**
*Build arcade-style house clearing with infinite replayability*

### **Day 12: Procedural Generation Foundation (2025-06-08)**
- [ ] **FOUNDATION**: Room type system (living room, kitchen, bedroom, bathroom, entrance, storage)
- [ ] **FOUNDATION**: Room size constraints and generation rules (5-8 rooms per house)
- [ ] **FOUNDATION**: Basic house layout algorithm with connectivity validation
- [ ] **TESTABLE**: Generate simple rectangular rooms with proper connections
- [ ] **PLAYABLE**: Player can navigate through procedurally generated 3-room house

### **Day 13: Room Variety and Components (2025-06-09)**
- [ ] **FOUNDATION**: TileMap-based room generation with 32x32 grid system
- [ ] **FOUNDATION**: Component library (walls, doors, floors, furniture placeholders)
- [ ] **PLAYABLE**: Room merging system (kitchen + living room combinations)
- [ ] **PLAYABLE**: Furniture spawn points and room-specific layouts
- [ ] **TESTABLE**: Generated houses have logical room arrangements and tactical variety

### **Day 14: Loot and Spawn Integration (2025-06-10)**
- [ ] **PLAYABLE**: Room-specific loot tables (kitchen = food/medical, bedroom = ammo/personal)
- [ ] **PLAYABLE**: Zombie spawn logic per room type with appropriate behaviors
- [ ] **PLAYABLE**: Extraction point system (front door, back door, window exits)
- [ ] **TESTABLE**: Complete house clearing loop - enter, clear, loot, extract
- [ ] **OPTIMIZATION**: Performance validation with procedural generation

### **Day 15: Generation Polish and Variety (2025-06-11)**
- [ ] **PLAYABLE**: House size variation (small 5 rooms, medium 6-7 rooms, large 8 rooms)
- [ ] **PLAYABLE**: Destroyed walls and alternative entry points
- [ ] **PLAYABLE**: Locked doors and tactical routing challenges
- [ ] **TESTABLE**: Multiple generation runs produce varied, tactical layouts
- [ ] **FOUNDATION**: Save/load system for favorite generated layouts

### **Day 16: Zombie Variety Expansion (2025-06-12)**
- [ ] **PLAYABLE**: 5 zombie variants (Walker, Runner, Brute, Crawler, Spitter)
- [ ] **PLAYABLE**: Room-specific zombie behaviors (sleeping in bedrooms, feeding in kitchen)
- [ ] **PLAYABLE**: Zombie density scaling based on house size
- [ ] **TESTABLE**: Each zombie type creates distinct tactical challenges
- [ ] **FOUNDATION**: Zombie AI states and behavior trees

### **Day 17: Weapon and Item Expansion (2025-06-13)**
- [ ] **PLAYABLE**: 4 weapon types (pistol, rifle, shotgun, medical pack)
- [ ] **PLAYABLE**: Weapon-specific stats and behaviors (damage, range, ammo type)
- [ ] **PLAYABLE**: Room-specific weapon spawns (rifle in bedroom, shotgun in garage)
- [ ] **TESTABLE**: Weapon choice affects tactical approach to house clearing
- [ ] **FOUNDATION**: Weapon switching and inventory management

### **Day 18: Core Loop Validation (2025-06-14)**
- [ ] **PLAYABLE**: Complete mission loop - deploy, clear house, extract, repeat
- [ ] **PLAYABLE**: Mission success/failure consequences and progression
- [ ] **PLAYABLE**: Basic UI for house selection and difficulty options
- [ ] **TESTABLE**: 5-10 minute house clearing sessions are engaging and replayable
- [ ] **OPTIMIZATION**: Final performance tuning for 60fps with full systems

---

## **Phase 3: Content Polish (Days 19-25)**
*Expand content variety while maintaining arcade focus*

### **Day 19: UI and Interface (2025-06-15)**
- [ ] **PLAYABLE**: Professional inventory display (Tarkov-style grid system)
- [ ] **PLAYABLE**: Mission briefing and house preview system
- [ ] **PLAYABLE**: Post-mission summary with statistics and loot collected
- [ ] **TESTABLE**: Intuitive interface supports rapid house clearing sessions
- [ ] **FOUNDATION**: Complete UI framework for all game systems

### **Day 20: Audio Foundation (2025-06-16)**
- [ ] **PLAYABLE**: Sound effects for all weapons and zombie interactions
- [ ] **PLAYABLE**: Ambient house audio (creaking, wind, zombie sounds)
- [ ] **PLAYABLE**: UI feedback sounds and music system
- [ ] **TESTABLE**: Audio enhances tactical awareness and atmosphere
- [ ] **FOUNDATION**: Dynamic audio system with spatial positioning

### **Day 21: Progression Systems (2025-06-17)**
- [ ] **PLAYABLE**: Player skill progression (accuracy, health, speed improvements)
- [ ] **PLAYABLE**: Unlock system for new house types and difficulty modes
- [ ] **PLAYABLE**: Achievement system for tactical accomplishments
- [ ] **TESTABLE**: Long-term progression motivates repeated play sessions
- [ ] **FOUNDATION**: Save system for player progress and statistics

### **Day 22: Content Variety (2025-06-18)**
- [ ] **PLAYABLE**: 3 house archetypes (suburban, apartment, rural) with unique layouts
- [ ] **PLAYABLE**: Special room types (basement, attic, garage) with unique challenges
- [ ] **PLAYABLE**: Environmental hazards and interactive elements
- [ ] **TESTABLE**: Content variety supports extended gameplay sessions
- [ ] **FOUNDATION**: Modular content system for easy expansion

### **Day 23: Balance and Difficulty (2025-06-19)**
- [ ] **PLAYABLE**: Difficulty scaling system with player-selectable challenge levels
- [ ] **PLAYABLE**: Balanced resource economy (ammo scarcity vs. zombie density)
- [ ] **PLAYABLE**: Tutorial system teaching core mechanics with simple house
- [ ] **TESTABLE**: Difficulty curve provides appropriate challenge progression
- [ ] **OPTIMIZATION**: Performance optimization across all content

### **Day 24: Integration Testing (2025-06-20)**
- [ ] **PLAYABLE**: All systems working together seamlessly
- [ ] **TESTABLE**: Extended gameplay sessions validate full feature set
- [ ] **OPTIMIZATION**: Final content system performance tuning
- [ ] **DOCUMENTATION**: Player-facing documentation and help systems
- [ ] **FOUNDATION**: Release candidate build preparation

### **Day 25: Content Systems Complete (2025-06-21)**
- [ ] **PLAYABLE**: Complete arcade extraction shooter experience
- [ ] **TESTABLE**: 2+ hours of varied, replayable content
- [ ] **OPTIMIZATION**: Stable 60fps performance across all scenarios
- [ ] **DOCUMENTATION**: Complete content development pipeline
- [ ] **VALIDATION**: Commercial viability assessment

---

## **Phase 4: Asset Generation & Polish (Days 26-32)**
*Replace placeholders with AI-generated assets while maintaining playable build*

### **Day 26-27: Visual Asset Pipeline (2025-06-22 to 2025-06-23)**
- [ ] **VISUAL**: Set up AI art generation workflow (Midjourney/DALL-E)
- [ ] **VISUAL**: Replace player and zombie placeholders with AI sprites
- [ ] **VISUAL**: Generate house component tiles (walls, floors, doors, furniture)
- [ ] **TESTABLE**: Asset replacement maintains gameplay feel and performance
- [ ] **FOUNDATION**: Efficient asset pipeline for rapid iteration

### **Day 28-29: Audio and Effects (2025-06-24 to 2025-06-25)**
- [ ] **AUDIO**: AI-generated sound effects and ambient audio
- [ ] **VISUAL**: Particle effects for combat and environmental interactions
- [ ] **VISUAL**: Lighting system for atmosphere and tactical gameplay
- [ ] **TESTABLE**: Enhanced audiovisual feedback improves game feel
- [ ] **FOUNDATION**: Complete audiovisual asset integration

### **Day 30-31: Final Polish (2025-06-26 to 2025-06-27)**
- [ ] **UI**: Professional interface design with consistent visual style
- [ ] **OPTIMIZATION**: Final performance optimization and bug fixes
- [ ] **TESTING**: Comprehensive QA testing across all systems
- [ ] **DOCUMENTATION**: Final player documentation and help systems
- [ ] **RELEASE**: Build preparation and distribution setup

### **Day 32: Release Preparation (2025-06-28)**
- [ ] **RELEASE**: Final release candidate build
- [ ] **MARKETING**: Store page preparation and marketing materials
- [ ] **TESTING**: Final stability and compatibility testing
- [ ] **DOCUMENTATION**: Release notes and player guides
- [ ] **LAUNCH**: Commercial release preparation complete

---

## **Success Metrics**
- [ ] **Day 18**: Core house clearing loop is engaging and replayable
- [ ] **Day 25**: 2+ hours of varied procedural content
- [ ] **Day 32**: Release-ready commercial product

## **Risk Mitigation**
- Procedural generation creates infinite content variety without manual design bottlenecks
- Arcade focus eliminates complex simulation systems that could cause scope creep
- Placeholder-first development maintains immediate testability throughout
- Component-based architecture enables rapid iteration and expansion

## **Commercial Positioning**
- **Genre**: Arcade extraction shooter (Synthetik meets house clearing)
- **USP**: Infinite procedural house variety with tactical combat
- **Target Audience**: Fans of top-down shooters and extraction games
- **Session Length**: 5-10 minute house clearing runs
- **Replayability**: Procedural generation ensures unique layouts every run

