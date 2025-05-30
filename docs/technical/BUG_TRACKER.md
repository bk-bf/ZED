# ZED - Bug Tracker

**Project:** ZED - Zombie Extraction Deliverance  
**Development Philosophy:** Playable-First Development  
**Last Updated:** 2025-05-29

---

## **Bug Classification System**

Using Eisenhower Matrix for prioritization:
- **Quadrant 1:** Urgent & Important → Fix Immediately
- **Quadrant 2:** Important, Not Urgent → Schedule Next Sprint  
- **Quadrant 3:** Urgent, Not Important → Investigate After Core Features
- **Quadrant 4:** Neither Urgent nor Important → Backlog/Consider Closing

---

# **Development Process Integration**

### **Daily Standup Review**
- Review Quadrant 1 bugs before starting new features
- Assess if any Quadrant 2 bugs should be promoted
- Update bug status based on development progress

### **Sprint Planning**
- Schedule Quadrant 2 bugs based on development phase
- Consider bug fix effort in daily task planning
- Balance new feature development with bug resolution

### **Testing Protocol**
- Test related systems when fixing bugs
- Verify fixes don't introduce regressions
- Update documentation when bug reveals design issues

---

## **Known Technical Debt**

### **Zombie AI System**
- Simple obstacle avoidance needs refinement for production quality
- Collision separation behavior not implemented
- Line-of-sight checking could be optimized with spatial partitioning

### **Performance Monitoring**
- No automated performance regression testing
- Manual testing required for entity count scaling
- Memory leak detection relies on manual observation

---

**Last Updated:** 2025-05-31

**Next Review:** IMMEDIATE - Critical vision system bug blocking development  
**Bug Count:** 5 active (1 CRITICAL), 1 resolved  
**Critical Path Impact:** SEVERE - BUG-005 blocks all feature development  
**Development Confidence:** LOW - Core vision system compromised, requires immediate attention

**DEVELOPMENT STATUS: PAUSED** - Critical bug resolution required before proceeding


## **Quadrant 1: Critical Bugs (Fix Immediately)**

---

### **[ ] BUG-005: Player Vision System Memory Corruption**
**Priority:** CRITICAL  
**Severity:** High  
**Status:** ACTIVE - BLOCKING DEVELOPMENT  
**Reported:** 2025-05-31  
**Component:** PlayerSight Memory & Raycasting System

**Description:**  
Critical failures in the player vision/memory system causing zombies to completely disappear or appear inconsistently. The raycasting line-of-sight checks and memory state management are interfering with each other, creating inverted visibility behavior.

**Critical Issues:**
1. **Memory Corruption**: Moving back and forth behind walls causes zombies to be completely removed from vision instead of being stored in memory
2. **Inverted Visibility Logic**: Zombies behind walls vanish when entering sight range, then appear in memory when leaving sight range (opposite of expected behavior)
3. **Shooting Interference**: Rapid shooting while moving behind walls exacerbates memory corruption
4. **State Management Conflicts**: Raycasting checks and memory system are not properly synchronized

**Impact:**
- **GAME-BREAKING**: Core tactical mechanic completely unreliable
- **Player Experience**: Confusing and frustrating gameplay with zombies randomly appearing/disappearing
- **Development Blocker**: Cannot proceed with feature development while core vision system is broken
- **System Integrity**: Memory state corruption may affect other dependent systems

**Reproduction Steps:**
1. Approach zombies until they are visible and in sight range
2. Move player behind wall (zombies should become memory - darkened but visible)
3. Move back and forth between behind wall and line-of-sight multiple times
4. Fire bullets during movement transitions
5. **Result**: Zombies completely disappear or show inverted visibility behavior

**Expected Behavior:**
- Zombies in explored areas should remain visible as memories (darkened) when behind walls
- Zombies should become fully visible when line-of-sight is restored
- Memory state should persist regardless of player movement patterns
- Shooting should not affect vision state management

**Actual Behavior:**
- Zombies completely vanish from view when they should be in memory
- Visibility logic appears inverted (visible when should be memory, memory when should be visible)
- System becomes increasingly unreliable with repeated wall transitions
- Memory corruption accumulates over time

**Technical Root Cause (Suspected):**
- Race conditions between Area2D signals and raycasting checks
- Conflicting state management between `visible_entities`, `entities_in_range`, and `memory_entities` arrays
- Position freezing for memory entities interfering with real-time state updates
- Signal timing issues causing state transitions to occur out of order

**System Components Affected:**
- `PlayerSight._process()` continuous line-of-sight checking
- `PlayerSight._on_entity_entered_sight()` / `_on_entity_left_sight()` signal handlers
- Memory entity position freezing in `_process()` loop
- `_add_to_memory()` / `_remove_from_memory()` state management
- `_show_entity()` / `_hide_entity()` visibility control

**Business Impact:**
- **Development Velocity**: Blocks all feature development until resolved
- **Core Gameplay**: Tactical stealth/visibility mechanics unusable
- **Player Trust**: Game appears fundamentally broken
- **Technical Debt**: May require significant refactoring of vision system

**Required Resolution:**
Complete audit and potential refactor of PlayerSight system:
1. Separate raycasting checks from Area2D signal handling
2. Implement proper state machine for entity visibility states
3. Fix memory entity position management conflicts
4. Add comprehensive state validation and error handling
5. Implement debug logging for state transitions

**Estimated Effort:** 8-12 hours (critical system refactor)  
**Business Value:** CRITICAL (core gameplay mechanic)  
**Target Resolution:** IMMEDIATE (Day 6 - before any new features)  
**Dependencies:** None - all other development blocked until resolved

**Debug Priority:** 
- Add comprehensive logging to all vision state transitions
- Implement state validation checks
- Create test scenarios for systematic debugging
- Consider temporary simplified implementation if refactor too complex

**Workaround:** None viable - affects core player experience

---

## **Quadrant 2: Important, Not Urgent (Schedule Next Sprint)**

### **[ ] BUG-001: Zombie Movement Algorithm Inefficiency**
**Priority:** High  
**Severity:** Medium  
**Status:** Documented for A* Replacement  
**Reported:** 2025-05-29  
**Updated:** 2025-05-31  
**Component:** Zombie AI Movement System

**Description:**  
Current zombie movement algorithm exhibits multiple pathfinding failures including:
- Zombies freezing in place during chase state despite having valid velocity
- Getting permanently stuck against walls and corners
- Inconsistent obstacle avoidance causing repetitive movement patterns
- Ray-cast based avoidance creates stuttering behavior around complex geometry

**Impact:**
- Breaks core chase mechanics unpredictably
- Creates frustrating player experience when zombies fail to pursue
- Affects tactical gameplay when zombies become non-threatening
- Reduces AI believability and game polish

**Detailed Issues:**
1. **Freeze Bug**: Zombies enter CHASING state with detected player and velocity but remain stationary
2. **Wall Sticking**: Simple ray-cast avoidance gets caught in infinite loops against walls
3. **Corner Traps**: 60-degree avoidance angles insufficient for complex corner navigation
4. **State Confusion**: Line-of-sight checks interfere with movement state management

**Debug Evidence:**
```
State: CHASING
Detected Player: Player:<CharacterBody2D#39107691860>
Target Position: (196.4155, 63.00317)
Current Position: (208.0752, 129.9806)
Velocity: (0.0, -246.2958)  // Has velocity but not moving
Player In Range: true
Has Line of Sight: true
```

**Technical Root Cause:**
Current movement system uses simple ray-casting with hardcoded angle rotations. This approach:
- Cannot handle complex pathfinding scenarios
- Lacks proper obstacle memory or planning
- Has no fallback for completely blocked scenarios
- Creates movement conflicts between different AI states

**Planned Resolution:**
Replace entire movement algorithm with A* pathfinding implementation:
- Grid-based or navigation mesh pathfinding
- Proper path planning and following
- Robust obstacle handling
- Separation from detection/state management systems

**Estimated Effort:** 12-16 hours (complete system replacement)  
**Business Value:** Very High (core gameplay mechanic)  
**Target Resolution:** Day 8-9 (A* pathfinding implementation)  
**Dependencies:** Core gameplay loop validation complete

**Workaround:** None viable - fundamental algorithm limitation

---

### **[ ] BUG-002: Corner Navigation Inefficiency**
**Priority:** Medium  
**Severity:** Low  
**Status:** Superseded by BUG-001  
**Reported:** 2025-05-29  
**Component:** Zombie Pathfinding

**Description:**  
*NOTE: This bug is a subset of BUG-001 and will be resolved by A* implementation*

Zombies get temporarily stuck pressing against corners before eventually navigating around them. Movement appears "sticky" at wall intersections.

**Target Resolution:** Resolved by A* pathfinding (BUG-001)

---

### **[ ] BUG-003: Zombie Collision Overlap**
**Priority:** High  
**Severity:** Medium  
**Status:** Needs Investigation  
**Reported:** 2025-05-29  
**Component:** Zombie AI System

**Description:**  
Zombies occasionally overlap with each other during movement, creating unrealistic stacking behavior that affects tactical gameplay.

**Impact:**
- Breaks tactical positioning mechanics
- Creates visual inconsistencies
- May affect pathfinding calculations
- Reduces tactical challenge when zombies cluster

**Technical Notes:**
- Separate from movement pathfinding issues (BUG-001)
- Related to CharacterBody2D collision separation
- May need zombie-to-zombie collision detection
- Consider implementing separation steering behavior

**Estimated Effort:** 4-6 hours  
**Business Value:** High (affects core tactical gameplay)  
**Target Resolution:** Day 10 (after A* pathfinding stable)

---

### **[ ] BUG-004: Intermittent Zombie Chase Detection Failure**
**Priority:** Medium  
**Severity:** Low-Medium  
**Status:** Needs Investigation  
**Reported:** 2025-05-29  
**Component:** Area2D Sight Detection

**Description:**  
*NOTE: May be related to BUG-001 movement conflicts*

Zombies occasionally fail to chase player when entering Area2D sight range. Signal emission appears inconsistent. May be interference between detection and movement systems.

**Target Resolution:** Day 11 (after movement system stabilized)

---

## **Technical Debt - Movement System**

### **Current Algorithm Limitations**
- Ray-cast based obstacle avoidance (primitive approach)
- No path planning or goal-oriented behavior
- Hardcoded movement angles and distances
- State management mixed with movement logic
- No spatial awareness beyond immediate obstacles

### **A* Implementation Plan**
- Grid-based pathfinding for predictable behavior
- Separation of pathfinding from movement execution
- Configurable path recalculation frequency
- Integration with existing zombie state system
- Performance optimization for multiple zombies

**Implementation Priority:** After core gameplay loop validation (Day 7+)

---

## **Quadrant 3: Urgent, Not Important (Investigate After Core Features)**

---

---

## **Quadrant 4: Backlog (Low Priority)**

*No current backlog items*

---

## **Resolved Bugs**

### **[x] BUG-000: Recursive Damage Interface Calls**
**Status:** RESOLVED  
**Resolution Date:** 2025-05-27  
**Component:** Damage System

**Description:**  
DamageInterface calling entity take_damage methods which called back to DamageInterface created infinite recursion and stack overflow.

**Resolution:**  
Separated damage calculation from damage application. DamageInterface calculates final damage with resistances, entity methods apply calculated damage and handle responses.

---

## **Bug Reporting Guidelines**

### **Required Information**
- Clear description of unexpected behavior
- Steps to reproduce (if known)
- Expected vs actual behavior
- Component/system affected
- Impact on gameplay/development

### **Priority Guidelines**
- **Critical:** Blocks core development or breaks build
- **High:** Affects primary gameplay mechanics
- **Medium:** Affects secondary features or polish
- **Low:** Minor issues or edge cases

### **Severity Guidelines**
- **High:** Game-breaking, crashes, data loss
- **Medium:** Functional issues affecting gameplay
- **Low:** Visual/polish issues, minor inconsistencies

---

#
