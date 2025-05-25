# 🧟‍♂️ ZED - Zombie Extraction Deliverance - Daily Tasks Breakdown

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

---

**Expected Result:** Blue square (player) moves smoothly with WASD keys inside a gray-walled room with camera following. Immediate testability achieved - you can play the basic movement system right now.

**Next Day Preview:** Day 2 will add shooting (white squares) and static zombies (red squares) to this same test scene.
