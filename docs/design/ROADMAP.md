# 🧟‍♂️ ZED - Development Roadmap

## Project Overview
**Genre:** Top-down tactical looter shooter  
**Core Loop:** Clear zombie-infested buildings → Collect resources → Manage base → Repeat with increasing difficulty  
**Development Philosophy:** Playable-first development with immediate testability at every step  
**Target:** Commercial release with AI-generated assets

---

## Phase 1: Core Mechanics (Days 1-7)
*Build immediately testable core gameplay loop*

### Day 1: Foundation + Playable Movement (2025-05-25)
- [x] Set up project structure with clear separation: mechanics, placeholders, assets
- [x] Configure Jolt Physics for performance optimization  
- [x] Create comprehensive placeholder asset library (colored shapes, basic sprites)
- [x] **PLAYABLE:** Create test scene with player movement (blue square moves with WASD)
- [x] **PLAYABLE:** Add basic room with walls for collision testing
- [x] **TESTABLE:** Player can walk around a simple room immediately

### Day 2: Combat Foundation (2025-05-26)
- [x] **PLAYABLE:** Implement shooting system (click to shoot white squares toward cursor)
- [x] **PLAYABLE:** Add 5 static zombies (red squares) in test room
- [x] **PLAYABLE:** Bullets destroy zombies on contact
- [x] **TESTABLE:** Core combat loop works - walk, aim, shoot, kill
- [x] **DOCUMENTATION** Define primary mechanic: tactical building clearance with resource management consequences

### Day 3: Health & Consequences (2025-05-27)
- [x] **PLAYABLE:** Add player health system with visual health bar
- [x] **PLAYABLE:** Zombies damage player on contact
- [x] **PLAYABLE:** Death restarts the test scene (consequence simulation)
- [x] **FOUNDATION:** Implement basic damage system for all entities

### **Day 4: Resource Management (2025-05-28)**
- [x] **FOUNDATION:** ItemData class with static database methods and dictionary-based zombie loot pools
- [x] **PLAYABLE:** Dictionary-driven ammo system with ItemData integration and counter UI
- [x] **PLAYABLE:** Loot pool-configured pickups spawn from zombie death with configurable drop rates
- [x] **PLAYABLE:** ItemData-respecting collection system with stack limits and pickup feedback

### Day 5: Simple AI & Challenge (2025-05-29)
- [x] **PLAYABLE:** Zombies chase player when in range
- [ ] **PLAYABLE:** Different zombie types with different speeds/health
- [ ] **PLAYABLE:** Spawn waves of zombies for escalating challenge
- [ ] **TESTABLE:** Tactical positioning and kiting mechanics
- [ ] **PLAYABLE:** Implement basic fog of war - unvisited areas are black, visited areas show memory
- [ ] **TESTABLE:** Tactical information management adds strategic room-to-room planning

### Day 6: Room Progression (2025-05-30)
- [ ] **PLAYABLE:** Multiple connected rooms with doors
- [ ] **PLAYABLE:** Player must clear each room to progress
- [ ] **PLAYABLE:** Final room has exit that completes "mission"
- [ ] **TESTABLE:** Building clearance concept with progression
- [ ] Basic procedural room generation

### Day 7: Core Loop Validation (2025-05-31)
- [ ] **PLAYABLE:** Complete mission loop - enter building, clear rooms, extract
- [ ] **PLAYABLE:** Loot collection with inventory display
- [ ] **PLAYABLE:** Mission success/failure with consequences
- [ ] **TESTABLE:** Full tactical building clearance mechanic
- [ ] Performance optimization for 60fps with 50+ entities

---

## Phase 2: Content Systems (Days 8-14)
*Expand playable content while maintaining testability*

### Day 8: Mission Variety (2025-06-01)
- [ ] **PLAYABLE:** 3 different building layouts (small, medium, large)
- [ ] **PLAYABLE:** Different zombie densities per mission type
- [ ] **PLAYABLE:** Mission selection screen with difficulty indicators
- [ ] **TESTABLE:** Variety in tactical challenges
- [ ] Mission system with objectives and rewards

### Day 9: Base Management Foundation (2025-06-02)
- [ ] **PLAYABLE:** Simple base screen with resource counters
- [ ] **PLAYABLE:** Spend collected resources on upgrades
- [ ] **PLAYABLE:** Upgrades affect next mission (more health, ammo, etc.)
- [ ] **TESTABLE:** Resource management consequences between missions
- [ ] Basic base building mechanics

### Day 10: Weapon Variety (2025-06-03)
- [ ] **PLAYABLE:** 3 weapon types (pistol, rifle, shotgun) with different stats
- [ ] **PLAYABLE:** Weapon switching during missions
- [ ] **PLAYABLE:** Weapons found as loot in buildings
- [ ] **TESTABLE:** Tactical weapon choice for different situations
- [ ] Weapon system with stats and behaviors

### Day 11: Survivor Management (2025-06-04)
- [ ] **PLAYABLE:** Recruit survivors found in buildings
- [ ] **PLAYABLE:** Assign survivors to base tasks
- [ ] **PLAYABLE:** Survivors can be injured and need recovery
- [ ] **TESTABLE:** Risk of losing valuable team members
- [ ] Survivor AI and management systems

### Day 12: Advanced Building Generation (2025-06-05)
- [ ] **PLAYABLE:** Procedurally generated building layouts
- [ ] **PLAYABLE:** Different building types (house, office, warehouse)
- [ ] **PLAYABLE:** Environmental hazards and interactive elements
- [ ] **TESTABLE:** Varied tactical scenarios
- [ ] **PLAYABLE:** Implement directional vision cone system for tactical awareness
- [ ] **TESTABLE:** Horror tension from limited vision and zombie flanking opportunities
- [ ] Procedural generation algorithms

### Day 13: Progression Systems (2025-06-06)
- [ ] **PLAYABLE:** Player skill progression (accuracy, health, speed)
- [ ] **PLAYABLE:** Unlockable equipment and base upgrades
- [ ] **PLAYABLE:** Achievement system for tactical accomplishments
- [ ] **TESTABLE:** Long-term progression motivation
- [ ] Character progression and unlocks

### Day 14: Content Integration (2025-06-07)
- [ ] **PLAYABLE:** All systems working together in cohesive experience
- [ ] **PLAYABLE:** Balanced difficulty curve across multiple missions
- [ ] **PLAYABLE:** Complete gameplay loop from tutorial to endgame
- [ ] **TESTABLE:** Full game experience validation
- [ ] Save/load system implementation

---

## Phase 3: AI Asset Generation (Days 15-21)
*Replace placeholders while maintaining playable build*

### Day 15: Asset Pipeline Setup (2025-06-08)
- [ ] **PLAYABLE:** Maintain current game with placeholder swapping system
- [ ] Set up AI art generation workflow (Midjourney/DALL-E)
- [ ] Create asset specification documents
- [ ] **TESTABLE:** Asset replacement doesn't break gameplay
- [ ] Establish art style and consistency guidelines

### Day 16: Character Assets (2025-06-09)
- [ ] **PLAYABLE:** Replace player and zombie placeholders with AI sprites
- [ ] Generate character variations and animations
- [ ] **TESTABLE:** New art improves game feel without changing mechanics
- [ ] Implement sprite animation system

### Day 17: Environment Assets (2025-06-10)
- [ ] **PLAYABLE:** Replace building tiles with detailed AI-generated textures
- [ ] Generate furniture and environmental objects
- [ ] **TESTABLE:** Enhanced visual clarity improves tactical decisions
- [ ] Create tileset and environmental art

### Day 18: Weapon & Item Assets (2025-06-11)
- [ ] **PLAYABLE:** Replace weapon and loot placeholders with detailed sprites
- [ ] Generate UI icons and interface elements
- [ ] **TESTABLE:** Clear visual communication of item properties
- [ ] Implement item and weapon art

### Day 19: Effects & Polish Assets (2025-06-12)
- [ ] **PLAYABLE:** Add particle effects, muzzle flashes, blood spatters
- [ ] Generate ambient and atmospheric elements
- [ ] **TESTABLE:** Enhanced feedback improves combat feel
- [ ] Create visual effects and particles

### Day 20: Audio Integration (2025-06-13)
- [ ] **PLAYABLE:** Add AI-generated sound effects and music
- [ ] Implement audio feedback for all actions
- [ ] **TESTABLE:** Audio enhances tactical awareness and immersion
- [ ] Complete audio implementation

### Day 21: Asset Polish (2025-06-14)
- [ ] **PLAYABLE:** Final asset integration and consistency pass
- [ ] Optimize all assets for performance
- [ ] **TESTABLE:** Professional visual quality maintained at 60fps
- [ ] Final art optimization and integration

---

## Phase 4: Polish & Release (Days 22-28)
*Maintain playable build while adding commercial features*

### Day 22: UI/UX Polish (2025-06-15)
- [ ] **PLAYABLE:** Professional menu systems and interface design
- [ ] Implement accessibility features
- [ ] **TESTABLE:** Intuitive user experience for new players
- [ ] Complete UI/UX implementation

### Day 23: Tutorial & Onboarding (2025-06-16)
- [ ] **PLAYABLE:** Interactive tutorial teaching core mechanics
- [ ] Create difficulty options and accessibility settings
- [ ] **TESTABLE:** New players can learn and enjoy the game
- [ ] Tutorial and help systems

### Day 24: Performance Optimization (2025-06-17)
- [ ] **PLAYABLE:** Maintain 60fps on target hardware
- [ ] Optimize for different screen resolutions
- [ ] **TESTABLE:** Smooth performance across all content
- [ ] Final performance optimization

### Day 25: Content Balancing (2025-06-18)
- [ ] **PLAYABLE:** Balanced difficulty curve and progression
- [ ] Fine-tune all game systems based on playtesting
- [ ] **TESTABLE:** Engaging challenge throughout entire game
- [ ] Balance and difficulty tuning

### Day 26: Bug Fixing & Stability (2025-06-19)
- [ ] **PLAYABLE:** Stable, crash-free experience
- [ ] Fix all critical and major bugs
- [ ] **TESTABLE:** Reliable gameplay experience
- [ ] Quality assurance and bug fixes

### Day 27: Release Preparation (2025-06-20)
- [ ] **PLAYABLE:** Final release candidate build
- [ ] Prepare store pages and marketing materials
- [ ] **TESTABLE:** Commercial-ready product
- [ ] Release preparation and marketing

### Day 28: Launch (2025-06-21)
- [ ] **RELEASED:** ZED available for purchase
- [ ] Monitor launch metrics and player feedback
- [ ] **SUCCESSFUL:** Commercial game development completed
- [ ] Launch and post-launch support

---

## Success Metrics
- **Daily:** Playable build with new features
- **Weekly:** Complete gameplay systems validation
- **Phase 1:** Core tactical combat loop proven fun
- **Phase 2:** Full content experience engaging
- **Phase 3:** Professional visual quality achieved
- **Phase 4:** Commercial product successfully launched

## Development Principles
1. **Playable First:** Every feature must be immediately testable
2. **Incremental Progress:** Each day builds on proven foundations
3. **Constant Validation:** Regular playtesting and feedback integration
4. **Commercial Focus:** All decisions support successful product launch
5. **Performance Priority:** Maintain 60fps throughout development

---

## Phase 5: Launch & Post-Launch Strategy (Week 5-6)

### Week 5: Early Access Launch (Deadline: 2025-06-28)
- [ ] Release Steam Early Access build (2025-06-22)
- [ ] Announce on anonymous social media (2025-06-22)
- [ ] Conduct press outreach using prepared materials (2025-06-22)
- [ ] Engage community through development blog (2025-06-22)
- [ ] Monitor Steam reviews and player feedback daily (2025-06-28)
- [ ] Engage on social media with generated content (2025-06-28)
- [ ] Follow up with press and coordinate interviews (2025-06-28)
- [ ] Provide player support and community management (2025-06-28)

### Week 6: Post-Launch Optimization & Growth (Deadline: 2025-07-05)
- [ ] Post regular development updates anonymously (2025-07-05)
- [ ] Integrate player feedback and communicate roadmap (2025-07-05)
- [ ] Engage on Steam forums and provide support (2025-07-05)
- [ ] Create ongoing marketing content (2025-07-05)
- [ ] Analyze sales data and optimize conversion (2025-07-05)
- [ ] Evaluate marketing channel effectiveness (2025-07-05)
- [ ] Analyze player behavior for future updates (2025-07-05)
- [ ] Refine revenue optimization and pricing strategy (2025-07-05)

## Success Metrics & Commercial Viability

### Technical Validation Targets
- [ ] Core Mechanics: Validated as engaging by Day 7 (2025-05-31)
- [ ] Asset Pipeline: Efficient workflow established by Day 15 (2025-06-08)
- [ ] Visual Consistency: Professional quality achieved by Day 21 (2025-06-14)
- [ ] Performance: Stable 60fps across target platforms by Day 25 (2025-06-18)

### Commercial Success Metrics
**Launch Targets (Month 1):**
- [ ] Sales: 300-800 copies in first week (2025-06-29)
- [ ] Reviews: 85%+ positive rating on Steam (2025-06-29)
- [ ] Wishlist Conversion: 15-25% conversion rate (2025-06-29)
- [ ] Revenue: $2,400-6,400 (at $8 price point) (2025-06-29)

**Growth Targets (Months 2-6):**
- [ ] Total Sales: 3,000-8,000 copies (2025-11-01)
- [ ] Revenue: $24,000-64,000 (2025-11-01)
- [ ] Community: 1,000+ engaged players (2025-11-01)
- [ ] Market Position: Top 25% of indie releases in genre (2025-11-01)

### Investment Analysis
**Development Costs:**
- [ ] AI Tools: $100-200 (Stable Diffusion, audio generation) (2025-06-08)
- [ ] Steam Direct Fee: $100 (one-time) (2025-06-16)
- [ ] Domain/Hosting: $15/year (2025-06-15)
- [ ] Total Investment: ~$300-400 (2025-06-18)

**ROI Projections:**
- [ ] Conservative: 6,000% return ($24,000 revenue on $400 investment) (2025-11-01)
- [ ] Optimistic: 16,000% return ($64,000 revenue on $400 investment) (2025-11-01)
