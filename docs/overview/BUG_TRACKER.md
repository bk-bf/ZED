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

**Next Review:** Day 6 - After core AI features complete  
**Bug Count:** 3 active, 1 resolved  
**Critical Path Impact:** None (no Quadrant 1 bugs)  
**Development Confidence:** High - all bugs are manageable and don't block core development


## **Quadrant 1: Critical Bugs (Fix Immediately)**

*Currently no critical bugs blocking core development*

---

## **Quadrant 2: Important, Not Urgent (Schedule Next Sprint)**

### **[ ] BUG-001: Zombie Collision Overlap**
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

**Reproduction Steps:**
1. Spawn multiple zombies in close proximity
2. Have player move to trigger chase behavior
3. Observe zombies converging on player position
4. Notice occasional overlap/stacking

**Expected Behavior:**  
Zombies should maintain separation while pursuing player, creating natural spacing for tactical engagement.

**Technical Notes:**
- Likely related to CharacterBody2D collision layers
- May need zombie-to-zombie collision detection
- Consider implementing separation steering behavior

**Estimated Effort:** 4-6 hours  
**Business Value:** High (affects core tactical gameplay)  
**Target Resolution:** Day 6 (after core AI features complete)

---

## **Quadrant 3: Urgent, Not Important (Investigate After Core Features)**

### **[ ] BUG-002: Corner Navigation Inefficiency**
**Priority:** Medium  
**Severity:** Low  
**Status:** Acknowledged  
**Reported:** 2025-05-29  
**Component:** Zombie Pathfinding

**Description:**  
Zombies get temporarily stuck pressing against corners before eventually navigating around them. Movement appears "sticky" at wall intersections.

**Impact:**
- Creates visual polish issues
- Slightly reduces AI believability
- Does not break core gameplay mechanics
- May cause minor performance overhead from repeated collision checks

**Reproduction Steps:**
1. Position zombie with player on opposite side of corner
2. Trigger chase behavior
3. Observe zombie pressing into corner before pathfinding around
4. Notice eventual successful navigation but inefficient movement

**Expected Behavior:**  
Zombies should smoothly navigate around corners without getting temporarily stuck.

**Technical Notes:**
- Current simple obstacle avoidance works but needs refinement
- May require multiple raycasts with angle checking
- Consider implementing corner detection and avoidance algorithms
- Alternative: Add "unstuck" timer mechanism as temporary fix

**Estimated Effort:** 6-8 hours (complex pathfinding optimization)  
**Business Value:** Low-Medium (polish/feel improvement)  
**Target Resolution:** Post Day 7 (after core loop validation)

### **[ ] BUG-003: Intermittent Zombie Chase Detection Failure**
**Priority:** Medium  
**Severity:** Low-Medium  
**Status:** Needs Investigation  
**Reported:** 2025-05-29  
**Component:** Area2D Sight Detection

**Description:**  
Zombies occasionally fail to chase player when entering Area2D sight range. Signal emission appears inconsistent. Rare occurrence, exact reproduction steps unknown.

**Impact:**
- Affects core chase mechanics unpredictably
- Could create player confusion during testing
- Does not completely break gameplay
- Inconsistent player experience

**Reproduction Steps:**
*Unable to consistently reproduce - appears random*
1. Move player into zombie sight range
2. Occasionally zombie fails to transition to chase state
3. No clear pattern identified

**Expected Behavior:**  
Zombies should consistently detect and chase player when entering sight range Area2D.

**Technical Notes:**
- May be related to Area2D signal timing
- Could be collision layer configuration issue
- Possible Godot engine timing bug
- Consider adding debug logging to sight range signals

**Estimated Effort:** 2-4 hours investigation  
**Business Value:** Medium (affects core loop reliability)  
**Target Resolution:** Day 6 (investigate during AI polish phase)

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
