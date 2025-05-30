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

## Day 5: Simple AI & Challenge (2025-05-29)

**Sub-task 1.1: Basic zombie movement foundation**
1. [x] Add `speed` property to ZombieData with default value 50 pixels/second
2. [x] Implement `get_direction_to_player()` method in zombie.gd calculating normalized vector
3. [x] Add `move_toward_target(delta)` method using CharacterBody2D velocity and move_and_slide()
4. [x] Set zombie detection range to 300 pixels using distance calculation
5. [x] Test single zombie follows player smoothly when approached

**Sub-task 1.2: Detection and state management**
1. [x] Create ZombieState enum with IDLE, CHASING, ATTACKING states in zombie.gd
2. [x] Implement `detect_player()` method checking distance and line-of-sight
3. [x] Add state transition logic - IDLE to CHASING when player enters range
4. [x] Implement `lose_player()` method returning to IDLE when player escapes sight_range 
5. [x] Test zombie state changes work correctly with visual feedback (color changes)

**Sub-task 1.3: Chase behavior optimization**
1. [x] Add `target_position` property to track last known player location
2. [x] Implement pathfinding around walls using simple obstacle avoidance
3. [x] Add slight randomization to movement to prevent perfect stacking
4. [x] Ensure zombies don't push each other through walls during chase
5. [-] Test multiple zombies chase player without getting stuck on walls

### **Task 2: Create zombie variety - different types with unique stats and behaviors**

**Sub-task 2.1: Zombie type system foundation**
1. [x] Create ZombieType enum with WALKER, RUNNER, BRUTE types in EntitesType
2. [x] Add `zombie_type` property to ZombieData with type-specific stat loading
3. [x] Define type stats: WALKER (100hp, 50speed), RUNNER (75hp, 100speed), BRUTE (200hp, 30speed)
4. [x] Update zombie.gd to use ZombieData type properties for health and speed
5. [ ] Test each zombie type spawns with correct stats and visual differentiation

**Sub-task 2.2: Visual type identification**
1. [ ] Assign distinct colors: WALKER (red), RUNNER (orange), BRUTE (dark red)
2. [ ] Scale zombie ColorRect based on type: WALKER (32x32), RUNNER (24x24), BRUTE (48x48)
3. [ ] Add type indicator to DebugManager zombie counter display
4. [ ] Ensure collision shapes match visual sizes for each type
5. [ ] Test all three types are visually distinct and properly sized

**Sub-task 2.3: Type-specific behavior implementation**
1. [ ] Add `damage_amount` property varying by type: WALKER (25), RUNNER (20), BRUTE (40)
2. [ ] Implement different detection ranges: WALKER (150), RUNNER (200), BRUTE (100)
3. [ ] Add type-specific movement patterns: RUNNER uses burst movement, BRUTE charges
4. [ ] Update zombie spawning to randomly select from available types
5. [ ] Test each type behaves distinctly and creates different tactical challenges

### **Task 3: Implement wave spawning system - escalating zombie pressure over time**

**Sub-task 3.1: Wave manager foundation**
1. [ ] Create `scripts/managers/wave_manager.gd` as AutoLoad singleton
2. [ ] Add wave configuration: wave_number, zombies_per_wave, spawn_delay properties
3. [ ] Implement `start_wave()` method spawning zombies at timed intervals
4. [ ] Add spawn points around room perimeter avoiding player starting position
5. [ ] Test first wave spawns 3 zombies with 2-second intervals

**Sub-task 3.2: Escalation mechanics**
1. [ ] Implement wave progression: each wave adds +2 zombies and reduces spawn delay by 0.2s
2. [ ] Add zombie type distribution: early waves mostly WALKERS, later waves include RUNNERS/BRUTES
3. [ ] Create `calculate_next_wave()` method determining composition and timing
4. [ ] Add wave completion detection when all zombies in current wave are eliminated
5. [ ] Test wave difficulty increases appropriately over 3-4 waves

**Sub-task 3.3: Wave UI and feedback**
1. [ ] Add wave counter UI showing "Wave X/∞" in top-right corner
2. [ ] Implement wave start notification with 3-second countdown
3. [ ] Add zombie remaining counter for current wave
4. [ ] Create wave completion message with brief pause before next wave
5. [ ] Test wave progression provides clear feedback and appropriate pacing

### **Task 4: Validate tactical positioning mechanics - kiting, chokepoints, resource management**

**Sub-task 4.1: Kiting mechanics validation**
1. [ ] Test player can maintain distance from WALKER zombies while shooting
2. [ ] Verify RUNNER zombies create pressure requiring tactical repositioning
3. [ ] Ensure ammunition scarcity forces careful shot placement during kiting
4. [ ] Test corner and wall usage for breaking line-of-sight and resetting zombie pursuit
5. [ ] Validate that kiting feels tactical rather than tedious

**Sub-task 4.2: Chokepoint and positioning tactics**
1. [ ] Test doorway positioning allows engaging one zombie at a time
2. [ ] Verify wall corners provide cover and tactical advantage
3. [ ] Ensure zombie pathfinding creates natural chokepoints at room entrances
4. [ ] Test that positioning mistakes result in being overwhelmed by multiple zombies
5. [ ] Validate that good positioning conserves ammunition and health

**Sub-task 4.3: Resource pressure and decision making**
1. [ ] Test ammunition scarcity creates meaningful engagement vs. avoidance decisions
2. [ ] Verify health damage from poor positioning has lasting consequences
3. [ ] Ensure wave escalation creates increasing resource pressure over time
4. [ ] Test that players must balance aggressive clearing vs. conservative survival
5. [ ] Validate that tactical mistakes have clear consequences while good play is rewarded

### **Task 5: Implement basic fog of war system - exploration and tactical information management**

**Sub-task 5.1: Fog of war rendering foundation**
1. [ ] Create `scripts/systems/fog_of_war.gd` managing visibility states
2. [ ] Add CanvasLayer with black ColorRect covering entire screen
3. [ ] Implement circular vision radius around player (100 pixel radius)
4. [ ] Use CanvasItem custom drawing to create visibility holes in fog
5. [ ] Test fog covers unseen areas and reveals areas around player

**Sub-task 5.2: Memory and exploration tracking**
1. [ ] Add explored area tracking using TileMap or area grid system
2. [ ] Implement "memory" state showing previously visited areas in gray
3. [ ] Ensure currently visible areas show full color and detail
4. [ ] Add smooth transition between unexplored (black), memory (gray), and visible (full color)
5. [ ] Test exploration reveals room layout permanently while maintaining current vision limits

**Sub-task 5.3: Tactical information integration**
1. [ ] Hide zombie positions outside current vision radius
2. [ ] Show zombie last-known positions in memory areas as faded indicators
3. [ ] Ensure fog of war affects zombie detection - they can't see player through walls
4. [ ] Add sound cues for zombie movement outside vision range
5. [ ] Test fog of war creates tactical decisions about room entry and positioning

**Expected Result:** Zombies actively hunt the player with distinct types creating varied threats. Wave system provides escalating challenge. Fog of war adds strategic exploration element. Core tactical loop of positioning, resource management, and information control is fully functional.

**Next Day Preview:** Day 6 will add multiple connected rooms with doors and progression mechanics, building toward the complete building clearance concept.
