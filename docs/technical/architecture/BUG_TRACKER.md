# ZED - Bug Tracker

**Project:** ZED 
**Development Philosophy:** Playable-First Development  
**Last Updated:** 2025-06-03

---

## **Bug Classification System**

Using Eisenhower Matrix for prioritization:
- **Quadrant 1:** Urgent & Important → Fix Immediately
- **Quadrant 2:** Important, Not Urgent → Schedule Next Sprint  
- **Quadrant 3:** Urgent, Not Important → Investigate After Core Features
- **Quadrant 4:** Neither Urgent nor Important → Backlog/Consider Closing

---

## **Current Development Status**

**BREAKTHROUGH ACHIEVED:** Core movement system completely resolved  
**Bug Count:** 3 remaining (0 CRITICAL), 6 resolved  
**Critical Path Impact:** NONE - All blocking issues resolved  
**Development Confidence:** MAXIMUM - Core systems validated and optimized  

**DEVELOPMENT STATUS: FULL SPEED** - All blocking issues resolved, feature development can proceed

---

## **Quadrant 1: Critical Bugs (Fix Immediately)**

---
*No critical bugs remaining - all resolved*
---

## **Quadrant 2: Important, Not Urgent (Schedule Next Sprint)**

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
- Separate from movement pathfinding issues (now resolved)
- Related to CharacterBody2D collision separation
- May need zombie-to-zombie collision detection
- Consider implementing separation steering behavior

**Estimated Effort:** 4-6 hours  
**Business Value:** High (affects core tactical gameplay)  
**Target Resolution:** Next sprint (after current remaining issues)

---

## **Quadrant 3: Urgent, Not Important (Investigate After Core Features)**

---

## **Quadrant 4: Backlog (Low Priority)**

---

### **[ ] BUG-006: Memory Zombies Movement Visibility**
**Priority:** Medium  
**Severity:** Medium (affects immersion)  
**Status:** READY - Fix proposed
**Reported:** 2025-06-03  
**Component:** Memory System Visual Behavior

**Description:**  
Players can see zombies moving when zombies are in memory mode (outside vision range/behind walls). This breaks intended game design where memory zombies should appear frozen at their last known position.

**Design Intent:** Memory zombies should appear frozen to maintain tactical immersion
**Current Behavior:** Memory zombies continue showing movement (useful for debugging)

**Impact:**
- Affects tactical immersion (players see "impossible" movement)
- Breaks intended memory system design
- Not game-breaking but reduces polish

**Technical Cause:**
```gdscript
# In zombie.gd - zombies continue physics processing even in memory
func _physics_process(delta):
    match zombie_data.state:
        ZombieData.ZombieState.CHASING:
            chase_target(delta)  # Still moves in memory
```

**Solution Implemented:**
```gdscript
func _physics_process(delta):
    # Check if zombie is in memory before processing movement
    var player_sight = get_tree().get_first_node_in_group("player_sight")
    var in_memory = false
    if player_sight and player_sight.memory_data.has(zombie_id):
        in_memory = true
    
    if in_memory:
        velocity = Vector2.ZERO  # Freeze movement in memory
        return
    
    # ... rest of physics processing
```

**Debug Toggle Available:**
```gdscript
@export var debug_show_memory_movement: bool = false
# Skip freeze if debug flag enabled for testing
```

**Estimated Effort:** 10 minutes  
**Business Value:** Medium (immersion and design consistency)  
**Target Resolution:** When you want proper game behavior vs. debug convenience


### **[ ] BUG-008: Visual Glitches - Ghost Zombies**
**Priority:** Low  
**Severity:** Low (cosmetic only)  
**Status:** DEFERRED  
**Reported:** 2025-06-03  
**Component:** ColorRect Rendering System

**Description:**  
Weird visual artifacts when zombies transition between states, especially behind walls. Ghost zombies occasionally appear during state transitions.

**Technical Cause:**
Current ColorRect-based rendering system limitations:
- State transition timing mismatches
- Modulation conflicts between systems
- Draw order issues with memory markers

**Resolution Decision:** **DEFER** - Will be replaced by sprite system anyway. Not worth debugging temporary ColorRect system.

**Estimated Effort:** 10 minutes (quick fix attempt)  
**Business Value:** Low (will be replaced)  
**Target Resolution:** When sprite system implemented

---

### **[ ] BUG-009: Memory Zombie Darkening Enhancement**
**Priority:** Trivial  
**Severity:** Trivial  
**Status:** READY - 2-minute fix  
**Reported:** 2025-06-03  
**Component:** Memory Visual System

**Description:**  
Memory zombies need better visual distinction - current darkening insufficient.

**Instant Fix Available:**
```gdscript
# In _create_memory_marker_from_zombie():
var memory_color = Color(
    original_color.r * 0.2,  # CHANGED: 0.3 -> 0.2 (darker)
    original_color.g * 0.2,  # CHANGED: 0.3 -> 0.2 (darker)
    original_color.b * 0.2,  # CHANGED: 0.3 -> 0.2 (darker)
    0.8                      # CHANGED: 0.7 -> 0.8 (more opaque)
)
```

**Estimated Effort:** 2 minutes  
**Business Value:** Trivial (visual polish)  
**Target Resolution:** Next session

---

## **Resolved Bugs**

---

### **[x] BUG-007: Respawn Performance Breakdown**
**Status:** RESOLVED ✅  
**Resolution Date:** 2025-06-03  
**Resolution Time:** 5 seconds (accidental discovery)  
**Component:** Scene Transition & Memory System

**Root Cause:** Synchronous `add_child()` calls during scene reload blocking main thread

**Solution Applied:**
```gdscript
# Changed from:
get_tree().current_scene.add_child(marker)
# To:
get_tree().current_scene.add_child.call_deferred(marker)
```

**Performance Results:**
- **Before:** drops to min. 7 FPS for 1-3 seconds on respawn
- **After:** Zero performance issues, even improved initial performance
- **Validation:** 5 consecutive respawns tested - flawless performance

**Discovery Method:** Accidental observation during FPS counter implementation
**Mood Impact:** EXHILARATED! 🚀


### **[x] BUG-005: Player Vision System Multi-Component Failure**
**Status:** RESOLVED  
**Resolution Date:** 2025-06-03  
**Component:** PlayerSight, Zombie AI, Memory System  
**Resolution Effort:** ~16 hours analysis + 6 hours implementation

**Description:**  
Critical multi-system failure affecting zombie movement, state transitions, memory system, and performance. What initially appeared as a "vision system memory corruption" was actually a seven-part system breakdown.

**Root Causes Identified and Fixed:**
1. **LOS Detection Parameter Mismatch** - Zombie and PlayerSight systems using different raycast parameters
2. **State Management Logic Failures** - Zombies stuck in IDLE despite detecting players behind walls
3. **Memory System Interference** - Arbitrary exploration grid preventing valid memory storage
4. **Visual System Component Error** - Attempting to clone non-existent Sprite2D instead of actual ColorRect
5. **Missing Debug Infrastructure** - State change logging methods didn't exist, making issues invisible
6. **Performance Configuration Error** - 25x oversized sight radius causing excessive LOS checks
7. **Last Known Position Management** - Improper tracking of player position when LOS broken

**Resolution Impact:**
- **✅ Movement System:** Perfect zombie behavior, no more stuck/frozen zombies
- **✅ Performance:** LOS checks reduced from 16+/frame to <5/frame
- **✅ Memory System:** Fully functional with proper visual markers
- **✅ Debug Infrastructure:** Complete observability across all systems
- **✅ State Transitions:** Reliable IDLE ↔ CHASING with proper logging

**Key Lesson:** Complex behavioral bugs often require multi-system analysis rather than single-point fixes.


### **[x] BUG-001: Zombie Movement Algorithm Inefficiency**
**Status:** RESOLVED (via BUG-005 resolution)  
**Resolution Date:** 2025-06-03  
**Component:** Zombie AI Movement & State Management

**Description:**  
Originally identified as pathfinding algorithm limitations, revealed to be state management and LOS detection issues during BUG-005 investigation.

**Resolution:**  
Fixed through BUG-005 multi-system resolution:
- Corrected state transition logic
- Fixed LOS detection parameters
- Proper last-known-position tracking
- Eliminated zombie "freezing" behavior

**Original A* Implementation Plan:** No longer needed - current movement system works perfectly after fixes.


### **[x] BUG-002: Corner Navigation Inefficiency**
**Status:** RESOLVED (subset of BUG-001)  
**Resolution Date:** 2025-06-03  
**Component:** Zombie Movement

**Description:**  
Zombie corner navigation issues resolved through BUG-005 comprehensive fixes.


### **[x] BUG-004: Intermittent Zombie Chase Detection Failure**
**Status:** RESOLVED  
**Resolution Date:** 2025-06-03  
**Component:** State Management & LOS Detection

**Description:**  
Zombies failing to chase players when in sight range. Resolved through BUG-005 state management and LOS detection fixes.


### **[x] BUG-000: Recursive Damage Interface Calls**
**Status:** RESOLVED  
**Resolution Date:** 2025-05-27  
**Component:** Damage System

**Description:**  
DamageInterface calling entity take_damage methods which called back to DamageInterface created infinite recursion and stack overflow.

**Resolution:**  
Separated damage calculation from damage application. DamageInterface calculates final damage with resistances, entity methods apply calculated damage and handle responses.

---

## **Development Achievements**

### **BUG-005 Resolution: Project Transformation**

**Before Resolution:**
- **Development Status:** BLOCKED - Core system appeared broken
- **Technical Confidence:** LOW - Architecture questioned
- **Debug Capabilities:** LIMITED - Overwhelmed by 10K+ line logs, missing observability
- **System Understanding:** POOR - Convoluted methods impossible to track
- **Performance:** POOR - Excessive computational overhead (25x oversized detection)
- **Player Experience:** FRUSTRATING - Unreliable zombie behavior, constant "freezing"

**After Resolution:**
- **Development Status:** ✅ UNBLOCKED - Core systems validated and perfected
- **Technical Confidence:** ✅ MAXIMUM - Architecture proven solid through systematic analysis
- **Debug Capabilities:** ✅ REVOLUTIONARY - AI-assisted log analysis + visual architecture mapping
- **System Understanding:** ✅ COMPLETE - Flowcharts document all system interactions
- **Performance:** ✅ OPTIMIZED - LOS checks reduced from 16+/frame to <5/frame
- **Player Experience:** ✅ SMOOTH - Reliable, predictable zombie mechanics

### **Methodology Revolution: The Two Critical Breakthroughs**

The BUG-005 resolution established a **revolutionary debugging methodology** combining:

#### **Breakthrough #1: AI-Assisted Log Analysis**
**Discovery:** GitHub Copilot can parse massive 10K+ line debug logs and create concise, immediately actionable analysis summaries.

**Impact:** 
- Eliminated fear of "debug spam" - transformed data volume from liability to asset
- Enabled full utilization of extensive debug logging infrastructure
- Created repeatable methodology for complex system debugging

#### **Breakthrough #2: Visual Architecture Analysis** 
**Discovery:** Creating detailed flowcharts of convoluted systems (`player_sight.gd` and `zombie.gd`) revealed fundamental design flaws invisible through code inspection alone.

**The Critical Insight:** Memory system was **freezing entire zombie AI** instead of storing position data - the root cause that cascaded into 7 system failures.

**Visual Debug Enhancement:** Adding zombie labels (ID, state, memory reference) made 10K+ line logs correlatable with actual game behavior, enabling real-time state transition observation.

### **Core Discovery: Architectural Design Flaw**

**Root Cause:** Instead of storing last known zombie position when leaving sight range or breaking LOS, the system **froze the entire zombie including its AI state machine**, causing zombie state transition malfunction.

**Resolution Required:** 7-step systematic fix addressing cascading failures:
1. Core memory system architecture redesign
2. LOS detection parameter standardization  
3. State management logic overhaul
4. Performance configuration correction (25x oversized detection radius)
5. Memory system requirement cleanup
6. Visual system component fixes
7. Debug infrastructure implementation

**Total Resolution Effort:** ~8 hours systematic implementation after breakthrough discoveries.

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

### **Revolutionary Lessons from BUG-005**
- **AI assistance transforms debugging:** Never avoid comprehensive logging when AI can synthesize results
- **Visual architecture analysis is essential:** Complex systems require flowcharts - code inspection alone is insufficient
- **System design flaws cascade:** Architectural problems create multi-system failures requiring systematic resolution
- **Debug infrastructure is foundation:** You can't fix what you can't see - invest in observability first

**Future Impact:** Systematic debugging capability established for any technical challenge - debugging time reduced from days/weeks to minutes/hours.

---

**DEVELOPMENT CONFIDENCE: MAXIMUM**  
**CORE SYSTEMS: FULLY VALIDATED**  
**NEXT PHASE: FEATURE DEVELOPMENT AT FULL SPEED** 🚀
