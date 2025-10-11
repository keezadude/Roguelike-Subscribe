# 🔍 PRE-TESTING BUG HUNT PROMPT
## Comprehensive Bug & Oversight Detection Before Integration Testing

**Purpose**: Systematically find integration issues, stubs, incomplete implementations, and potential bugs BEFORE attempting to run the game.

**Context**: This is a LÖVE2D game project combining Truck Dismount gameplay with roguelike progression. The codebase claims to be "complete" but needs thorough verification of actual integration vs documented claims.

---

## 📋 COPY THIS PROMPT FOR NEW SESSION

```
# OBJECTIVE: Pre-Testing Bug Hunt & Integration Verification

You are performing a comprehensive pre-testing audit of a LÖVE2D game project. Your goal is to find bugs, integration issues, stub implementations, and oversights BEFORE attempting to run the game.

## PROJECT CONTEXT:
- **Game**: "Roguelike & Subscribe" - Truck Dismount meets Meta-Progression
- **Engine**: LÖVE2D (Lua-based game engine)
- **Status**: Weeks 0-5 claimed "complete", Week 5 partially integrated
- **Location**: `C:\Users\kylea\OneDrive\Desktop\GAME_DEV\LOVE2D Project\Roguelike & Subscribe`

## CRITICAL BACKGROUND:
Previous QA found that despite documentation claiming 96% completion, the shop UI was a STUB with placeholder text "(Shop UI to be implemented)" even though a full 350-line ShopUI.lua existed but wasn't integrated. This was missed because the reviewer trusted documentation without verifying actual integration.

## YOUR MISSION:
Find ALL issues like this before testing. Be SKEPTICAL of documentation claims. Verify everything.

---

## 🎯 PHASE 1: STUB & PLACEHOLDER DETECTION (30 minutes)

### 1.1: Grep for Suspicious Patterns
Search the ENTIRE src/ directory for:

```bash
# Stub indicators
- "TODO"
- "FIXME" 
- "HACK"
- "XXX"
- "STUB"
- "NOT IMPLEMENTED"
- "to be implemented"
- "placeholder"
- "temporary"
- "PLACEHOLDER"
- "WIP"
- "Work in progress"

# Suspicious print statements
- "print.*stub"
- "print.*todo"
- "print.*not.*implement"
```

**For each finding**:
1. Document exact location (file:line)
2. Determine if it's critical (in production code) or benign (in tests/comments)
3. Assess impact on functionality
4. Create fix recommendation

### 1.2: Function Body Analysis
Search for minimal/empty function implementations:

```lua
# Patterns to find:
- Functions that only return nil
- Functions with only print statements
- Functions with single-line stubs like "-- TODO: implement"
- Functions returning hardcoded values instead of real logic
```

**Check these files specifically**:
- `src/game/game-manager.lua` - Master coordinator
- `src/ui/*.lua` - All UI files
- `src/systems/*.lua` - All game systems
- `src/progression/*.lua` - Progression/shop systems

### 1.3: Look for Apologetic Comments
```lua
# Find patterns like:
- "-- This should be..."
- "-- Temporary..."
- "-- Quick hack..."
- "-- Not ideal..."
- "-- Need to fix..."
- "-- Simplified..."
```

---

## 🔗 PHASE 2: INTEGRATION VERIFICATION (45 minutes)

### 2.1: Require Statement Audit

**For `src/game/game-manager.lua`**:
1. List ALL require() statements at the top
2. For EACH required module:
   - Verify the file actually exists
   - Check if the module is actually USED in the code (not just imported)
   - Confirm it's initialized in the constructor
   - Verify it's called in update/draw loops if needed

**Create a table**:
```
| Module | Required? | File Exists? | Initialized? | Used? | Status |
|--------|-----------|--------------|--------------|-------|--------|
| ShopUI | Yes       | Yes          | Yes          | Yes   | ✅     |
```

### 2.2: Claimed vs Actual Features

**Check documentation claims against reality**:

For each WEEK*_COMPLETE.md file:
1. Read claimed features
2. Grep for the feature name in actual code
3. Verify it's not just declared but ACTUALLY IMPLEMENTED
4. Check if UI elements exist and are RENDERED
5. Verify state machine transitions exist

**Example checks**:
- Claim: "Shop UI with visual upgrade cards"
  - File exists? ✅
  - Imported in game-manager? ⚠️ CHECK THIS
  - Initialized? ⚠️ CHECK THIS  
  - Called in draw()? ⚠️ CHECK THIS
  - NOT a stub? ⚠️ CHECK THIS

### 2.3: State Machine Completeness

**In `game-manager.lua` find `registerStates()`**:

For EACH state (MAIN_MENU, SETUP, GAMEPLAY, RESULTS, SHOP, PAUSE):
1. Check if enter() callback exists
2. Check if update() callback exists and actually updates systems
3. Check if draw() callback exists and renders something
4. Check if keypressed() callback handles inputs
5. Verify draw() doesn't just print placeholder text

**Red flags**:
```lua
draw = function()
    love.graphics.print("Coming soon...", 400, 300)  // ← STUB!
end

draw = function()
    -- TODO: implement
end  // ← STUB!
```

### 2.4: Cross-Reference State Handlers

For each draw*() function in game-manager:
- `drawMainMenu()`
- `drawShop()`
- `drawResults()`
- `drawGameWorld()`
- `drawPauseOverlay()`

**Verify each one**:
1. Does it call imported UI systems? (good)
2. Or does it only use basic love.graphics.print()? (suspicious)
3. Does it have apologetic comments like "(Shop UI to be implemented)"? (STUB!)

---

## 💾 PHASE 3: SAVE/LOAD VERIFICATION (20 minutes)

### 3.1: Evidence of Testing
**Check for save files**:
```bash
# Search for:
- *.sav
- *.json (in save directory)
- savegame*
- gamedata*
```

**No save files found = Game has NEVER been run successfully**

### 3.2: Save Manager Code Review

**Read `src/game/save-manager.lua`**:
1. Does it actually write to disk? (check for file I/O)
2. Does it use json encoding? (check for json.encode)
3. Are there try/catch or pcall() protections?
4. Does it handle missing files gracefully?
5. Is it called in love.quit()?

### 3.3: Save Data Structure
Verify the save data structure is comprehensive:
```lua
# Should include:
- totalSubscribers
- totalRuns
- upgradeLevels
- unlockedCharacters/trucks/levels
- achievements
- statistics
```

If missing critical data = incomplete implementation

---

## 🎮 PHASE 4: GAMEPLAY LOOP VERIFICATION (30 minutes)

### 4.1: Collision Detection Implementation

**In `game-manager.lua` find `checkCollisions()`**:

**Verify it's REAL**:
```lua
// RED FLAG (stub):
function GameManager:checkCollisions()
    -- TODO: implement collision detection
end

// GREEN FLAG (real):
function GameManager:checkCollisions()
    local contacts = self.vehicle.chassis:getContacts()
    for _, contact in ipairs(contacts) do
        // ... 20+ lines of actual logic
    end
end
```

**Check if it**:
1. Actually gets contacts from physics world
2. Iterates through contacts
3. Identifies collision partners
4. Calls damage calculator
5. Updates score
6. Spawns effects
7. Plays sounds

### 4.2: Damage Calculation

**Read `src/systems/damage-calculator.lua`**:

**Verify it actually calculates**:
1. Uses kinetic energy formula (KE = 0.5 * m * v²)
2. Applies body part multipliers
3. Has minimum threshold
4. Returns structured result
5. Not just returning random numbers

**Red flag**: `return {damage = math.random(10, 100)}` ← fake

### 4.3: Score System Integration

**Check `src/systems/score-manager.lua`**:
1. Does it track combos?
2. Does it calculate multipliers?
3. Does it track achievements (headshots, airtime, etc)?
4. Is it updated every frame?
5. Is it displayed in HUD?

**Verify in game-manager**:
```lua
// Should have in GAMEPLAY update:
self.scoreManager:update(dt)
self.scoreHUD:update(dt)
```

### 4.4: Launch Control

**Check `src/ui/launch-control.lua`**:
1. Does charging actually work?
2. Does it have a power meter calculation?
3. Does it trigger vehicle launch callback?
4. Is the callback actually wired in game-manager?

**In game-manager constructor, verify**:
```lua
self.launchControl = LaunchControl:new({
    onLaunch = function(power)
        self:launchVehicle(power)  // ← Must exist
    end
})
```

---

## 🎨 PHASE 5: UI SYSTEM VERIFICATION (30 minutes)

### 5.1: UI File Inventory

**List ALL files in `src/ui/`**:
```
For each file:
- Does it export a module?
- Is it imported in game-manager?
- Is it initialized?
- Is it called in appropriate state?
```

**Common culprits** (files that exist but aren't used):
- `menu-manager.lua` (if game-manager has own menu)
- `statistics-ui.lua` (often forgotten)
- `shop-ui.lua` (was forgotten before)
- Custom UI components

### 5.2: HUD Elements

**Verify during GAMEPLAY state**:
```lua
// Should render:
- Score display
- Combo counter
- Damage numbers (floating text)
- Power meter (during launch)
- Debug info (toggle with F1)
```

**Check in `drawGameWorld()`**:
```lua
self.scoreHUD:draw()  // ← Must be present
```

### 5.3: Achievement Notifications

**Check `src/ui/achievement-notification.lua`**:
1. Is it imported in game-manager?
2. Is it initialized?
3. Is it updated in main update loop (NOT just in GAMEPLAY)?
4. Is it drawn AFTER everything else (top layer)?

**Critical check**:
```lua
function GameManager:update(dt)
    self.stateMachine:update(dt)
    self.achievementNotification:update(dt)  // ← Must be here (global)
end

function GameManager:draw()
    self.stateMachine:draw()
    self.achievementNotification:draw()  // ← Must be here (top layer)
end
```

---

## ⚡ PHASE 6: WEEK 4 & 5 FEATURES (30 minutes)

### 6.1: Camera System Integration

**Verify in GAMEPLAY state update**:
```lua
// Should have:
self.camera:update(dt)

// In drawGameWorld():
self.camera:attach()
// ... draw game objects
self.camera:detach()
```

**If camera system exists but isn't used = week 4 not integrated**

### 6.2: Particle System

**Check for particle spawning in collision handler**:
```lua
function GameManager:handleVehicleRagdollCollision(...)
    // Should have:
    self.particleSystem:createImpactEffect(cx, cy, intensity)
    self.particleSystem:createDebrisEffect(...)
    // etc.
end
```

**If particle system exists but never called = not integrated**

### 6.3: Screen Effects

**Check in GAMEPLAY update**:
```lua
self.screenEffects:update(dt)

// In collision handler:
if damageResult.damage > 80 then
    self.screenEffects:flashImpact(damageResult.damage)
    self.screenEffects:slowMotion(0.3, 0.2)
end
```

### 6.4: Achievement Checks

**Verify in `calculateResults()`**:
```lua
// Should call:
local newAchievements = self.achievementSystem:checkAchievements(stats)

// Should queue notifications:
for _, achievement in ipairs(newAchievements) do
    self.achievementNotification:notify(achievement)
end
```

**If achievement system exists but never checked = not functional**

---

## 🔍 PHASE 7: DEEP CODE INSPECTION (30 minutes)

### 7.1: Nil Check Patterns

**Search for dangerous patterns**:
```lua
// BAD (will crash):
self.vehicle:update(dt)  // If vehicle is nil = crash

// GOOD (safe):
if self.vehicle then
    self.vehicle:update(dt)
end
```

**Check ALL entity updates** in GAMEPLAY loop for nil guards.

### 7.2: Array Iteration Safety

**Check ragdoll/entity loops**:
```lua
// Verify proper iteration:
for _, ragdoll in ipairs(self.ragdolls) do
    if ragdoll then  // ← Good to have
        ragdoll:update(dt)
    end
end
```

### 7.3: Physics Body Cleanup

**In entity destruction, verify**:
```lua
function Entity:destroy()
    if self.body then
        self.body:destroy()  // ← Must clean up Box2D bodies
        self.body = nil
    end
end
```

**If bodies aren't destroyed = memory leak**

### 7.4: Callback Function Existence

**Search for callbacks being set**:
```lua
// Setting callback:
onLaunch = function(power)
    self:launchVehicle(power)
end

// MUST verify launchVehicle() exists:
function GameManager:launchVehicle(power)
    // ... implementation
end
```

---

## 🏗️ PHASE 8: ARCHITECTURE VERIFICATION (20 minutes)

### 8.1: Module Return Statements

**Every Lua module MUST end with**:
```lua
return ModuleName
```

**Check ALL files in src/** for missing return statements**

### 8.2: Constructor Patterns

**Verify proper OOP**:
```lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass:new(...)
    local self = setmetatable({}, MyClass)
    // ... initialization
    return self  // ← Must return self
end

return MyClass  // ← Must return class
```

### 8.3: Require Path Correctness

**Verify all require statements use proper paths**:
```lua
// CORRECT:
require('src.game.game-manager')

// WRONG (will fail):
require('src/game/game-manager')  // Using slashes instead of dots
require('game-manager')  // Missing src prefix
```

### 8.4: Circular Dependency Check

**Look for circular requires**:
- Module A requires Module B
- Module B requires Module A
- = Crash on load

**Common culprits**:
- Entity classes requiring each other
- UI components requiring game-manager
- Game-manager requiring UI that requires game-manager

---

## 📋 PHASE 9: DOCUMENTATION VS REALITY (15 minutes)

### 9.1: Cross-Reference All WEEK*_COMPLETE.md Files

**For each file**:
1. List claimed features
2. Verify each feature actually exists in code
3. Mark as:
   - ✅ Implemented and integrated
   - ⚠️ Implemented but not integrated
   - ❌ Not implemented (documented only)

### 9.2: File Existence Check

**From documentation, list all claimed files**:
```
For each file path mentioned:
- Does it exist? (use file search)
- Is it imported anywhere?
- Is it used in game logic?
```

### 9.3: Feature Completeness Matrix

**Create this table**:
```
| Feature | Claimed | Code Exists | Integrated | Tested | Status |
|---------|---------|-------------|------------|--------|--------|
| Shop UI | Week 5  | Yes         | NOW (was no)| No     | ⚠️     |
```

---

## 📊 DELIVERABLES

### Create these documents:

1. **BUG_HUNT_FINDINGS.md**
   - All stubs found with line numbers
   - All integration gaps discovered
   - All missing features identified
   - Severity ratings (Critical/High/Medium/Low)

2. **INTEGRATION_STATUS_MATRIX.md**
   - Every system: File exists? Imported? Initialized? Used?
   - Color-coded status (✅/⚠️/❌)
   - Completion percentages per week

3. **PRE_TEST_FIX_LIST.md**
   - Prioritized list of fixes needed BEFORE testing
   - Estimated time per fix
   - Step-by-step fix instructions
   - Dependencies between fixes

4. **CRITICAL_ISSUES_SUMMARY.md**
   - Top 10 issues that will prevent testing
   - Each with: Location, Problem, Impact, Fix

5. **REALISTIC_COMPLETION_ASSESSMENT.md**
   - Honest percentage complete per system
   - Evidence-based assessment
   - No assumptions, only verified facts
   - Confidence levels for each assessment

---

## ⚠️ RULES FOR THIS AUDIT

### DO:
1. ✅ Verify EVERYTHING against actual code
2. ✅ Use grep/search to find patterns
3. ✅ Read actual function bodies, not just names
4. ✅ Check if features are CALLED, not just defined
5. ✅ Look for apologetic comments
6. ✅ Check for save files (evidence of running)
7. ✅ Cross-reference docs against reality
8. ✅ Be SKEPTICAL of completion claims
9. ✅ Rate confidence levels honestly
10. ✅ Document every finding with line numbers

### DON'T:
1. ❌ Trust documentation without verification
2. ❌ Assume file exists = feature works
3. ❌ Assume imported = integrated
4. ❌ Skip reading function implementations
5. ❌ Accept "looks good" without evidence
6. ❌ Give high confidence without testing
7. ❌ Overlook placeholder text in draw functions
8. ❌ Ignore missing nil checks
9. ❌ Assume state handlers are complete
10. ❌ Be optimistic - be THOROUGH

---

## 🎯 SUCCESS CRITERIA

This audit is successful when you can answer:

1. ✅ How many stub implementations exist? (exact count with locations)
2. ✅ Which systems are documented but not integrated? (specific list)
3. ✅ Which UI systems exist but aren't used? (file names)
4. ✅ Are there any circular dependencies? (yes/no with examples)
5. ✅ Is the collision system actually implemented? (verified with code)
6. ✅ Does the shop actually work? (can purchases be made?)
7. ✅ Are particle effects actually spawned? (called in code?)
8. ✅ Does save/load exist? (evidence: save files or no?)
9. ✅ What's the REAL completion percentage? (evidence-based)
10. ✅ Can this game run right now? (honest assessment)

---

## 📈 EXPECTED OUTCOME

After this audit, you should produce:

**A brutally honest assessment** of:
- What actually works vs what's claimed
- What needs to be fixed before testing
- What integration work remains
- How long until it's actually testable
- Realistic completion percentage (not optimistic)

**Your final statement should be**:
> "Based on this audit, the project is X% complete, with Y critical issues, Z integration gaps, and will require N hours of work before it's ready for integration testing. Confidence: M%."

Where X, Y, Z, N, M are EVIDENCE-BASED numbers, not guesses.

---

## 🚀 BEGIN AUDIT

Start with Phase 1 and work through systematically.
Document findings as you go.
Be thorough, be skeptical, be honest.

The user needs to know the TRUTH before attempting to test.

Your previous session found the shop UI stub by getting suspicious and digging deeper. Do that for EVERY system.

Good luck. 🔍
```

---

## 📝 USAGE INSTRUCTIONS

### How to Use This Prompt:

1. **Start a fresh Claude session**
2. **Copy the entire prompt above** (from "OBJECTIVE" to "Good luck")
3. **Paste it as your first message**
4. **Let Claude work through all 9 phases**
5. **Review the deliverable documents**
6. **Fix issues found before attempting to test**

### Expected Duration:
- Claude's audit: 3-4 hours
- Fixing issues found: 4-8 hours (depends on severity)
- **Total before testing**: 1-2 days

### Why This Works:
- **Systematic**: Covers all aspects methodically
- **Evidence-based**: Requires proof, not assumptions
- **Skeptical**: Learned from shop UI stub mistake
- **Actionable**: Produces fix lists, not just findings
- **Honest**: Forces realistic assessments

---

**Prompt Status**: ✅ Ready to Use  
**Recommended Use**: Before any integration testing  
**Estimated Value**: Saves 1-2 weeks of debugging during testing  
**Confidence**: Very High (learned from real experience)

*This prompt embodies everything I should have done in the first place.* 🎯
