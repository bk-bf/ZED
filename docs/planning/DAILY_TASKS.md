# 🧟‍♂️ ZED - Daily Tasks Breakdown

## How to Use This Document
- Each roadmap item is broken into 3 sub-tasks with 5 granular steps each
- Complete tasks in order for best results
- Each granular step should take 15-30 minutes maximum
- Test immediately after completing each sub-task
- Maximum 15 checkboxes per roadmap item to maintain momentum

---

## Day 1: Foundation + Playable Movement (2025-05-25)

- **PLAYABLE:** Create test scene with player movement (blue square moves with WASD)

#### Sub-task 1.1: Set up basic test scene
1. [x] Create new scene `scenes/testing/movement_test.tscn` with Node2D root
2. [x] Add CharacterBody2D node named "Player" as child
3. [x] Add CollisionShape2D to Player with RectangleShape2D (32x32)
4. [x] Save scene and verify it loads without errors
5. [x] Set scene as main scene in project settings

#### Sub-task 1.2: Create player visual and script
1. [x] Create `scripts/player_controller.gd` script file
2. [x] Attach script to Player CharacterBody2D node
3. [x] Add ColorRect child to Player (32x32 size, blue color)
4. [x] Position ColorRect at (0,0) relative to Player
5. [x] Test scene - blue square should be visible on screen

#### Sub-task 1.3: Implement WASD movement
1. [x] Add input handling in `_physics_process()` for WASD keys
2. [x] Implement velocity calculation using `Input.get_action_strength()`
3. [x] Add `move_and_slide()` call to apply movement
4. [x] Set player speed to 200 pixels/second
5. [x] Test movement - blue square moves smoothly with WASD

- **PLAYABLE:** Add basic room with walls for collision testing

#### Sub-task 2.1: Create wall structure
1. [x] Add Node2D named "Walls" as child of root scene
2. [x] Create 4 StaticBody2D nodes as children of Walls (Top, Bottom, Left, Right)
3. [x] Add CollisionShape2D to each wall with RectangleShape2D
4. [x] Size walls: Top/Bottom (800x32), Left/Right (32x600)
5. [x] Position walls to form enclosed 800x600 room

#### Sub-task 2.2: Make walls visible
1. [x] Add ColorRect child to each wall StaticBody2D
2. [x] Set ColorRect size to match collision shape
3. [x] Set all wall ColorRects to gray color (#808080)
4. [x] Position ColorRects at (0,0) relative to each wall
5. [x] Test scene - gray walls should be visible forming room boundaries

#### Sub-task 2.3: Test collision system
1. [x] Run scene and verify player spawns inside room
2. [x] Test collision - player should not move through walls
3. [x] Verify smooth sliding along walls when moving diagonally
4. [x] Check all 4 walls prevent player movement outside room
5. [x] Adjust player starting position to center of room (400, 300)

- **TESTABLE:** Player can walk around a simple room immediately

#### Sub-task 3.1: Add camera follow system
1. [x] Add Camera2D node as child of Player
2. [x] Enable Camera2D and set as current camera
3. [x] Set camera smoothing enabled with speed 5.0
4. [x] Test camera follows player movement smoothly
5. [x] Adjust camera limits to room boundaries if needed

#### Sub-task 3.2: Basic polishment of movement feel
1. [x] Test movement responsiveness and adjust speed if needed
2. [x] Verify diagonal movement is properly normalized
3. [x] Check movement *feels* smooth at 60fps
4. [x] Test edge cases (holding multiple keys, rapid direction changes)
5. [x] Ensure no jittering or stuttering during movement


**Expected Result:** Blue square (player) moves smoothly with WASD keys inside a gray-walled room with camera following. Immediate testability achieved - you can play the basic movement system right now.

---

## Day 2: Combat Foundation (2025-05-26)

### Task 1: Implement shooting system (click to shoot white squares toward cursor)

#### Sub-task 1.1: Create bullet scene and script
1. [x] Create new scene `scenes/gameplay/weapons/bullet.tscn` with Area2D root
2. [x] Add CollisionShape2D with CircleShape2D (radius 4) to bullet
3. [x] Add ColorRect child (8x8 size, white color) for visual
4. [x] Create `scripts/mechanics/bullet.gd` script extending Area2D
5. [x] Add velocity property and movement logic in `_physics_process()`

#### Sub-task 1.2: Add shooting to player controller
1. [x] Add bullet scene preload to player_controller.gd
2. [x] Implement mouse click detection in `_input()` function
3. [x] Calculate direction from player to mouse cursor on click
4. [x] Instantiate bullet at player position with calculated direction
5. [x] Test shooting - white squares should fly toward mouse cursor

#### Sub-task 1.3: Handle bullet lifecycle
1. [x] Add bullet lifetime timer (2 seconds) to prevent infinite bullet objects, that consume memory
2. [x] Remove bullets when they hit walls or leave screen bounds
3. [x] Test edge case: rapid clicking doesn't crash game
4. [x] Test edge case: bullets despawn properly when hitting walls
5. [x] Verify no memory leaks from bullet spawning/despawning

### Task 2: Add 5 static zombies (red squares) in test room

#### Sub-task 2.1: Create zombie scene and basic script
1. [x] Create new scene `scenes/gameplay/enemies/zombie.tscn` with CharacterBody2D root
2. [x] Add CollisionShape2D with RectangleShape2D (32x32) to zombie
3. [x] Add ColorRect child (32x32 size, red color) for visual
4. [x] Create `scripts/mechanics/zombie.gd` script with health property (100 HP)
5. [x] Add `take_damage(amount)` and `die()` functions

#### Sub-task 2.2: Spawn zombies in test scene
1. [x] Add 5 zombie instances to movement_test.tscn at fixed positions
2. [x] Position zombies around room: corners and center, avoiding player spawn
3. [x] Verify zombies don't overlap with walls or player starting position
4. [x] Test scene loads with all 5 red squares visible
5. [x] Ensure zombies don't move (static for now)

#### Sub-task 2.3: Test zombie collision boundaries
1. [x] Verify player can't walk through zombies
2. [-] Test edge case: player getting stuck between zombie and wall
3. [x] Ensure zombie collision shapes match visual size
4. [-] Test player can walk around zombies smoothly
5. [x] Verify camera still follows player with zombies present

### Task 3: Bullets destroy zombies on contact

#### Sub-task 3.1: Implement bullet-zombie collision
1. [x] Connect bullet's `body_entered` signal to collision handler
2. [x] Add collision detection between bullets and zombies
3. [x] Call zombie `take_damage(25)` when bullet hits
4. [x] Remove bullet immediately after hitting zombie
5. [x] Test single bullet kills zombie after 4 hits (100 HP / 25 damage)

#### Sub-task 3.2: Add zombie death handling
1. [x] Make zombie disappear when health reaches 0
2. [x] Add simple death effect (zombie fades out or disappears instantly)
3. [x] Ensure dead zombie collision is removed (player can walk through)
4. [x] Test edge case: multiple bullets hitting same zombie simultaneously
5. [x] Verify zombie counter decreases when zombies die

#### Sub-task 3.3: Polish combat feedback
1. [x] Add brief visual feedback when zombie takes damage (color flash)
2. [x] Ensure bullets don't pass through zombies to hit others behind
3. [x] Test edge case: shooting zombies at extreme angles
4. [x] Verify bullet-wall collision still works with zombie collision
5. [x] Test rapid-fire shooting at single zombie works correctly

### Task 4: Define primary mechanic - tactical building clearance with resource management consequences

#### Sub-task 4.1: Document core mechanic rules
1. [x] Create `docs/core_mechanics.md` file with tactical clearance definition
2. [x] Define death consequences: lose all carried equipment, restart mission
3. [x] Define success rewards: keep collected loot, return to base safely
4. [x] Specify resource constraints: limited ammo forces tactical decisions
5. [x] Document risk/reward balance: more dangerous areas have better loot

#### Sub-task 4.2: Plan resource management systems
1. [x] Define core resources: ammo, health, equipment durability, time
2. [x] Document how resources create tactical decisions (conserve vs aggressive)
3. [x] Plan permadeath consequences for team members and equipment
4. [x] Define mission structure: enter building → clear rooms → extract safely
5. [x] Document how resource scarcity drives tactical positioning choices


**Expected Result:** Click to shoot white squares at red zombie squares. Zombies die after 4 hits and disappear. Core tactical combat loop functional with documented game design foundation.

**Next Day Preview:** Day 3 will add player health, zombie damage, and death consequences to create risk/reward decisions.

---

# Day 3: Health & Consequences (2025-05-27)

## Sub-task 3.1: Player Health System
1. [x] Create `scripts/mechanics/health_system.gd` with max_health (100) and current_health properties
2. [x] Add health system to player_controller.gd with `take_damage(amount)` function
3. [x] Create simple health bar UI scene (`scenes/ui/health_bar.tscn`) with ProgressBar node
4. [x] Connect health bar to player health and position in top-left corner

## Sub-task 3.2: Zombie Contact Damage
1. [x] Add Area2D child to zombie for damage detection (separate from bullet collision)
2. [x] Set Area2D collision mask to detect player layer only
3. [x] Implement `_on_damage_area_body_entered()` in zombie.gd to damage player on contact
4. [x] Add damage cooldown (1 second) to prevent instant death from single zombie
5. [x] Test zombie damages player when touching, health bar decreases

## Sub-task 3.3: Death and Restart System
1. [x] Add `die()` function to player_controller.gd that triggers on health <= 0
2. [x] Implement scene restart using `get_tree().reload_current_scene()`
3. [x] Add brief death message display before restart (2 second delay)
4. [x] Reset DebugManager counters on scene restart for accurate tracking
5. [x] Test death restarts scene and resets all systems properly

## Sub-task 3.4: Universal Damage System Foundation
1. [x] Create `scripts/core/damage_interface.gd` with standard damage functions
2. [x] Ensure all entities (player, zombies) use consistent damage/health patterns
3. [x] Add damage type enum (BULLET, CONTACT, ENVIRONMENTAL) for future expansion
4. [x] Implement damage resistance system foundation for different entity types
5. [x] Test all damage sources work consistently across different entity types


**Expected Result:** Player has visible health, zombies are dangerous to approach, death has consequences (scene restart), and the risk/reward of close combat is established. Core damage system ready for Day 4's ammo scarcity mechanics.

**Next Day Preview:** Day 4 will add limited ammo system, forcing players to make tactical decisions about when to engage vs when to conserve resources.

---

# Day 4: Resource Management (2025-05-28)

## Sub-task 4.1: ItemData Foundation with Static Database
1. [x] Create `ItemData` resource class with `id`, `name`, `type`, `stack_size` properties and static database methods
2. [x] Implement static `get_item_by_id()` and `get_items_by_type()` methods with automatic `.tres` file loading
3. [x] Create `placeholder_pistol_ammo` ItemData with 30 `stack_size` and save as `res://data/items/placeholder_pistol_ammo.tres`
4. [x] Add `ItemType` enum (`AMMO`, `WEAPON`, `MEDICAL`, `CONSUMABLE`, `EQUIPMENT`,etc.) to `ItemData` class
5. [x] Test `ItemData.get_item_by_id("placeholder_pistol_ammo")` returns correct item properties

## Sub-task 4.2: Dictionary-Based Zombie Loot Pools
1. [x] Add `loot_pool` Dictionary to ZombieData with `"pistol_ammo": 1.0` (100% drop chance)
2. [x] Add `loot_amounts` Dictionary to ZombieData with amount ranges per item type
3. [x] Implement `get_loot_drops()` method that iterates `loot_pool` and generates drop arrays
4. [x] Update zombie `die()` function to call `get_loot_drops()` and spawn pickups accordingly
5. [x] Test zombie death consistently drops 3-8 pistol ammo with 100% reliability

## Sub-task 4.3: Ammo System Integration with ItemData
1. [x] Update `PlayerData` to reference `ItemData.get_item_by_id("placeholder_pistol_ammo")` for ammo properties
2. [x] Create ammo counter UI displaying current/max from `ItemData` properties
3. [x] Update `shoot_bullet()` to consume ammo and show "No ammo!" when inventory empty
4. [x] Test ammo system respects `ItemData` configuration without hardcoded values

## Sub-task 4.4: Item Pickup and Collection System
1. [x] Create `ItemPickup` scene with `setup(item_data, amount)` method for configurable drops
2. [x] Implement pickup collision detection that identifies `ItemData` type and amount
3. [x] Add `add_item()` method to `PlayerData` respecting `ItemData` `stack_size` limits
4. [x] Create pickup feedback showing item name and amount from `ItemData` properties
5. [x] Test pickup collection updates ammo counter and respects maximum capacity

**Expected Result:** Player inventory, ammo, and loot are fully data-driven. All item properties, drop rates, and collection mechanics are configured through `ItemData` and `ZombieData` dictionaries. 

Based on your ZED project's playable-first development philosophy and the established task breakdown pattern, here are the detailed subtasks for Day 5:

# Day 5: Simple AI & Challenge (2025-05-29)

### **Sub-task 1.1: Basic zombie movement foundation**
1. [x] Add `speed` property to ZombieData with default value 50 pixels/second
2. [x] Implement `get_direction_to_player()` method in zombie.gd calculating normalized vector
3. [x] Add `move_toward_target(delta)` method using CharacterBody2D velocity and move_and_slide()
4. [x] Set zombie detection range to 300 pixels using distance calculation
5. [x] Test single zombie follows player smoothly when approached

### **Sub-task 1.2: Detection and state management**
1. [x] Create ZombieState enum with IDLE, CHASING, ATTACKING states in zombie.gd
2. [x] Implement `detect_player()` method checking distance and line-of-sight
3. [x] Add state transition logic - IDLE to CHASING when player enters range
4. [x] Implement `lose_player()` method returning to IDLE when player escapes sight_range 
5. [x] Test zombie state changes work correctly with visual feedback (color changes)

### **Sub-task 1.3: Chase behavior optimization**
1. [x] Add `target_position` property to track last known player location
2. [x] Implement pathfinding around walls using simple obstacle avoidance
3. [x] Add slight randomization to movement to prevent perfect stacking
4. [x] Ensure zombies don't push each other through walls during chase
5. [-] Test multiple zombies chase player without getting stuck on walls

## **Task 2: Create zombie variety - different types with unique stats and behaviors**

### **Sub-task 2.1: Zombie type system foundation**
1. [x] Create ZombieType enum with WALKER, RUNNER, BRUTE types in EntitesType
2. [x] Add `zombie_type` property to ZombieData with type-specific stat loading
3. [x] Define type stats: WALKER (100hp, 50speed), RUNNER (75hp, 100speed), BRUTE (200hp, 30speed)
4. [x] Update zombie.gd to use ZombieData type properties for health and speed
5. [x] Test each zombie type spawns with correct stats and visual differentiation

## **Sub-task 2.2: Visual type identification**
1. [x] Assign distinct colors: WALKER (red), RUNNER (orange), BRUTE (dark red)
2. [x] Add type indicator to DebugManager zombie counter display
3. [x] Test all three types are visually distinct 

### **Sub-task 2.3: Type-specific behavior implementation**
1. [x] Add `damage` property varying by type: WALKER (25), RUNNER (20), BRUTE (40)
2. [x] Implement different detection ranges: WALKER (350), RUNNER (350), BRUTE (300)
3. [x] Update zombie spawning to randomly select from available types
4. [x] Test each type behaves distinctly and creates different tactical challenges

## **Task 3: Validate tactical positioning mechanics - kiting, chokepoints, resource management**

### **Sub-task 3.1: Kiting mechanics validation**
1. [x] Test player can maintain distance from WALKER zombies while shooting
2. [x] Verify RUNNER zombies create pressure requiring tactical repositioning  
3. [x] Ensure ammunition scarcity forces careful shot placement during kiting
4. [x] Test corner and wall usage for breaking line-of-sight and resetting zombie pursuit
5. [x] Validate that kiting feels tactical rather than tedious

## **Task 3: Implement Area2D sight range system with memory and wall occlusion**

### **Sub-task 3.1: Player sight range and zombie visibility foundation**
1. [x] Create `scripts/systems/player_sight.gd` managing zombie visibility states
2. [x] Add Area2D "SightRange" to player with CircleShape2D collision detection
3. [x] Implement zombie detection on `body_entered`/`body_exited` signals from player's sight range
4. [x] Add raycasting line-of-sight checks to prevent zombie detection through walls
5. [x] Test zombies become visible when entering player sight range and have clear line-of-sight

### **Sub-task 3.2: Memory system and explored area tracking**
1. [x] Implement explored area grid system tracking previously visited locations
2. [x] Add memory entity system showing zombies in darkened state when behind walls in explored areas
3. [x] Implement position freezing for memory entities (zombies don't move when in memory state)
4. [x] Add proper state management for visible/hidden/memory zombie states
5. [~~] **CRITICAL BUG**: Fix memory system corruption causing zombies to disappear or show inverted visibility

### **Sub-task 3.3: Debug visualization and system validation**
1. [x] Add F6 debug toggle for player sight range visualization (green circle)
2. [x] Implement F7 debug toggle for zombie sight ranges (red circles with transparency)
3. [x] Create comprehensive zombie state debugging (F9) showing detection, memory, and movement states
4. [x] Add debug output for sight range signals and line-of-sight calculations
5. [~~] **NEEDS COMPLETION**: Validate system stability and fix race conditions between signals and raycasting

**Expected Result:** Player has visible sight range showing which zombies can be detected. Zombies behind walls in explored areas appear as darkened memories. System provides tactical information about enemy positions while requiring exploration to reveal new areas.

**CRITICAL BLOCKER**: BUG-005 (Player Vision System Memory Corruption) must be resolved before proceeding to Day 6. The sight range and memory systems are experiencing race conditions and state management conflicts that make the core visibility mechanic unreliable.

**Completion Status**: 
- ✅ Core sight range detection working
- ✅ Basic memory system implemented  
- ✅ Debug visualization complete
- ❌ **System reliability critical failure** - requires immediate fix
- ❌ Memory corruption during wall transitions
- ❌ Inverted visibility logic under certain conditions

**Next Steps**: 
1. **IMMEDIATE**: Debug and fix PlayerSight memory system (BUG-005)
2. **THEN**: Validate system works reliably with rapid movement and shooting
3. **THEN**: Proceed to Day 6 multi-room implementation

---

## BUG-005: Vision System Memory Corruption Troubleshooting (2025-06-01)

**CRITICAL BUG:** Fix race conditions and memory corruption in PlayerSight system
**STATUS:** PARTIAL PROGRESS - 1 of 4 issues resolved
**IMPACT:** Core tactical mechanic partially stabilized

### 🔍 Root Cause Analysis Summary (From Debug Log)

#### ✅ Issue 1: **Infinite Search Loop** - RESOLVED
```
Zombie @CharacterBody2D@82 searching at distance: 245.957443237305
```
**Root Cause**: No search timeout mechanism, zombies stuck endlessly searching
**Fix Applied**: Implemented precise exit position tracking - zombies now move directly to player's sight range exit point and stop there
**Status**: ✅ COMPLETED - Zombies no longer get stuck in infinite search loops

#### ✅ Issue 2: **Rapid State Oscillation** - RESOLVED
```
[22:49:12] MEMORY_REMOVE_FROM_MEMORY: Entity=@CharacterBody2D@82 Position=(297.4263, -92.39612)
[22:49:12] VISIBILITY_CHANGE: Entity=@CharacterBody2D@82 MEMORY->HIDDEN
[22:49:12] RAYCAST_GAINED: Entity=@CharacterBody2D@82 Distance=509.3
[22:49:12] VISIBILITY_CHANGE: Entity=@CharacterBody2D@82 HIDDEN->VISIBLE
```
**Root Cause**: No debouncing on state changes within PlayerSight
**Required Fix**: Add minimum time interval between state changes
**Status**: ✅ COMPLETED - debouncing has been implemented for zombie and player

#### ❌ Issue 3: **Memory System Position Conflicts** - NEEDS FIX
```
entity.global_position = memory_entities[entity] # Forces position in _process
```
**Root Cause**: PlayerSight forcibly moves entities during physics updates
**Required Fix**: Use `call_deferred()` for position updates or stop forcing positions

#### ❌ Issue 4: **Signal Timing Race Conditions** - NEEDS FIX
```
Area2D signals firing during physics state changes
```
**Root Cause**: Signals processed immediately during physics updates
**Required Fix**: Use `call_deferred()` for signal processing

### Task 1: PlayerSight System Fixes (Issues 2, 3, 4)

#### Sub-task 1.1: Implement state change debouncing (Issue 2)
1. [ ] Add `last_state_change_time: Dictionary` to track per-entity change timing
2. [ ] Add `min_state_change_interval: float = 0.1` (100ms minimum between changes)
3. [ ] Create `_can_change_entity_state(entity)` method checking debounce timing
4. [ ] Update `_show_entity()`, `_hide_entity()`, `_add_to_memory()` to use debouncing
5. [ ] Test rapid state oscillation - verify changes limited to 10Hz maximum

#### Sub-task 1.2: Fix memory position management (Issue 3)
1. [ ] Remove `entity.global_position = memory_entities[entity]` from `_process()`
2. [ ] Store memory positions without forcing entity movement
3. [ ] Update memory visual state without changing entity physics position
4. [ ] Use `call_deferred()` for any remaining position updates
5. [ ] Test memory entities - verify they don't teleport or cause physics conflicts

#### Sub-task 1.3: Implement deferred signal processing (Issue 4)
1. [ ] Update `_on_entity_entered_sight()` to use `call_deferred("_handle_entity_entered", body)`
2. [ ] Update `_on_entity_left_sight()` to use `call_deferred("_handle_entity_left", body)`
3. [ ] Create `_handle_entity_entered()` and `_handle_entity_left()` deferred methods
4. [ ] Ensure all state changes happen outside physics frame processing
5. [ ] Test signal timing - verify no race conditions during rapid movement

### Task 2: State Validation & Cleanup

#### Sub-task 2.1: Implement comprehensive state validation
1. [ ] Create `_validate_entity_state(entity)` method checking for conflicts
2. [ ] Add validation: entity cannot be in multiple arrays simultaneously
3. [ ] Add validation: memory entities must have stored positions
4. [ ] Add validation: visible entities must have line-of-sight
5. [ ] Test validation - trigger warnings for inconsistent states

#### Sub-task 2.2: Create atomic state transitions
1. [ ] Create `_transition_entity_state(entity, new_state)` method for safe changes
2. [ ] Ensure all state changes go through single validation point
3. [ ] Add rollback capability if state transition fails validation
4. [ ] Implement proper cleanup when entities are destroyed/removed
5. [ ] Test atomic transitions - verify no partial state changes

#### Sub-task 2.3: Enhanced debug validation
1. [ ] Add state consistency checks to debug output
2. [ ] Implement `_debug_validate_all_states()` method for system health check
3. [ ] Add F12 debug key to trigger full system validation
4. [ ] Log any state inconsistencies found during validation
5. [ ] Test validation catches and reports all state corruption issues

### Task 3: System Integration Testing

#### Sub-task 3.1: Systematic reproduction scenario
1. [ ] Set up test scene with single zombie behind wall corner
2. [ ] Document exact player movement pattern that previously triggered bugs
3. [ ] Record baseline behavior with all fixes applied
4. [ ] Create reproducible test case validating all 4 issues are resolved
5. [ ] Verify no regression in zombie search behavior (Issue 1 stays fixed)

#### Sub-task 3.2: Multi-zombie stress testing
1. [ ] Test with 5+ zombies in various sight/memory/hidden states
2. [ ] Rapid movement through multiple wall transitions
3. [ ] Test concurrent zombie AI + PlayerSight processing
4. [ ] Verify system performance under stress conditions
5. [ ] Document any remaining edge cases or performance issues

#### Sub-task 3.3: Integration with zombie exit position tracking
1. [ ] Verify PlayerSight fixes don't interfere with zombie exit position system
2. [ ] Test zombie AI continues working correctly with debounced PlayerSight
3. [ ] Ensure zombie sight ranges work independently of PlayerSight fixes
4. [ ] Validate complete tactical visibility system functions as designed
5. [ ] Document final system behavior and performance characteristics

**Expected Result:** All 4 root causes of BUG-005 eliminated. Vision system stable and reliable. Zombies transition properly between visible/memory/hidden states without disappearing, oscillating, or causing physics conflicts.

**Critical Success Criteria:**
- ✅ Zombie infinite search loops eliminated (Issue 1 - COMPLETED)
- [ ] Zero rapid state oscillations during wall transitions (Issue 2)
- [ ] No entity position teleporting or physics conflicts (Issue 3)
- [ ] Stable signal processing without race conditions (Issue 4)
- [ ] Tactical visibility system reliable for gameplay decisions

**Validation Tests:**
- Move behind wall 10 times - zombies stay in memory (darkened) without oscillation
- Rapid shooting while moving - no vision state corruption or conflicts
- Multiple zombies behind different walls - all memory states preserved consistently
- Line-of-sight restoration - all zombies become visible without position glitches
- System handles 10+ entities in mixed states without performance degradation
