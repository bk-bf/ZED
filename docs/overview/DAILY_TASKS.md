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
1. [ ] Create new scene `scenes/gameplay/weapons/bullet.tscn` with Area2D root
2. [ ] Add CollisionShape2D with CircleShape2D (radius 4) to bullet
3. [ ] Add ColorRect child (8x8 size, white color) for visual
4. [ ] Create `scripts/mechanics/bullet.gd` script extending Area2D
5. [ ] Add velocity property and movement logic in `_physics_process()`

#### Sub-task 1.2: Add shooting to player controller
1. [ ] Add bullet scene preload to player_controller.gd
2. [ ] Implement mouse click detection in `_input()` function
3. [ ] Calculate direction from player to mouse cursor on click
4. [ ] Instantiate bullet at player position with calculated direction
5. [ ] Test shooting - white squares should fly toward mouse cursor

#### Sub-task 1.3: Handle bullet lifecycle
1. [ ] Add bullet lifetime timer (2 seconds) to prevent infinite bullets
2. [ ] Remove bullets when they hit walls or leave screen bounds
3. [ ] Test edge case: rapid clicking doesn't crash game
4. [ ] Test edge case: bullets despawn properly when hitting walls
5. [ ] Verify no memory leaks from bullet spawning/despawning

### Task 2: Add 5 static zombies (red squares) in test room

#### Sub-task 2.1: Create zombie scene and basic script
1. [ ] Create new scene `scenes/gameplay/enemies/zombie.tscn` with CharacterBody2D root
2. [ ] Add CollisionShape2D with RectangleShape2D (32x32) to zombie
3. [ ] Add ColorRect child (32x32 size, red color) for visual
4. [ ] Create `scripts/mechanics/zombie.gd` script with health property (100 HP)
5. [ ] Add `take_damage(amount)` and `die()` functions

#### Sub-task 2.2: Spawn zombies in test scene
1. [ ] Add 5 zombie instances to movement_test.tscn at fixed positions
2. [ ] Position zombies around room: corners and center, avoiding player spawn
3. [ ] Verify zombies don't overlap with walls or player starting position
4. [ ] Test scene loads with all 5 red squares visible
5. [ ] Ensure zombies don't move (static for now)

#### Sub-task 2.3: Test zombie collision boundaries
1. [ ] Verify player can't walk through zombies
2. [ ] Test edge case: player getting stuck between zombie and wall
3. [ ] Ensure zombie collision shapes match visual size
4. [ ] Test player can walk around zombies smoothly
5. [ ] Verify camera still follows player with zombies present

### Task 3: Bullets destroy zombies on contact

#### Sub-task 3.1: Implement bullet-zombie collision
1. [ ] Connect bullet's `body_entered` signal to collision handler
2. [ ] Add collision detection between bullets and zombies
3. [ ] Call zombie `take_damage(25)` when bullet hits
4. [ ] Remove bullet immediately after hitting zombie
5. [ ] Test single bullet kills zombie after 4 hits (100 HP / 25 damage)

#### Sub-task 3.2: Add zombie death handling
1. [ ] Make zombie disappear when health reaches 0
2. [ ] Add simple death effect (zombie fades out or disappears instantly)
3. [ ] Ensure dead zombie collision is removed (player can walk through)
4. [ ] Test edge case: multiple bullets hitting same zombie simultaneously
5. [ ] Verify zombie counter decreases when zombies die

#### Sub-task 3.3: Polish combat feedback
1. [ ] Add brief visual feedback when zombie takes damage (color flash)
2. [ ] Ensure bullets don't pass through zombies to hit others behind
3. [ ] Test edge case: shooting zombies at extreme angles
4. [ ] Verify bullet-wall collision still works with zombie collision
5. [ ] Test rapid-fire shooting at single zombie works correctly

### Task 4: Define primary mechanic - tactical building clearance with resource management consequences

#### Sub-task 4.1: Document core mechanic rules
1. [ ] Create `docs/core_mechanics.md` file with tactical clearance definition
2. [ ] Define death consequences: lose all carried equipment, restart mission
3. [ ] Define success rewards: keep collected loot, return to base safely
4. [ ] Specify resource constraints: limited ammo forces tactical decisions
5. [ ] Document risk/reward balance: more dangerous areas have better loot

#### Sub-task 4.2: Plan resource management systems
1. [ ] Define core resources: ammo, health, equipment durability, time
2. [ ] Document how resources create tactical decisions (conserve vs aggressive)
3. [ ] Plan permadeath consequences for team members and equipment
4. [ ] Define mission structure: enter building → clear rooms → extract safely
5. [ ] Document how resource scarcity drives tactical positioning choices

#### Sub-task 4.3: Validate mechanic with current test
1. [ ] Test current combat feels tactical (positioning matters for safety)
2. [ ] Verify shooting mechanics support careful, aimed gameplay
3. [ ] Ensure zombie placement creates tactical challenges (cover, angles)
4. [ ] Document what works and what needs improvement for tactical feel
5. [ ] Plan how current systems extend to full building clearance concept


**Expected Result:** Click to shoot white squares at red zombie squares. Zombies die after 4 hits and disappear. Core tactical combat loop functional with documented game design foundation.

**Next Day Preview:** Day 3 will add player health, zombie damage, and death consequences to create risk/reward decisions.

---
