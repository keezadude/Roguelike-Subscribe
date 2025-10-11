# ✅ INTEGRATION TEST CHECKLIST
## Step-by-Step Verification Guide

**Purpose**: Actually run the game and verify what works  
**Time Required**: 30-60 minutes  
**Status**: Ready to execute

---

## 🚀 PRE-TEST SETUP

### Requirements:
- [ ] LÖVE 2D installed (love2d.org)
- [ ] Project directory accessible
- [ ] Terminal/Command prompt open

### Location:
```
C:\Users\kylea\OneDrive\Desktop\GAME_DEV\LOVE2D Project\Roguelike & Subscribe
```

---

## 📋 TEST EXECUTION STEPS

### Step 1: Launch the Game

**Command**:
```batch
run-integrated.bat
```

**What Should Happen**:
- LÖVE window opens (1280x720)
- Console shows initialization messages
- Main menu appears

**If It Fails**:
- Note the exact error message
- Check which require() statement failed
- Look for file path errors
- Document for fixing

**Result**: [ ] PASS  [ ] FAIL

**Error Log** (if failed):
```
[Paste error message here]
```

---

### Step 2: Main Menu Navigation

**Test Actions**:
1. Observe main menu rendering
2. Check if subscriber count displays
3. Press 'S' to enter shop
4. Press 'ESC' to return to menu
5. Press 'SPACE' to start run

**What Should Happen**:
- Menu text renders clearly
- Total subscribers shows (should be 0)
- 'S' key opens shop
- 'ESC' returns to menu
- 'SPACE' transitions to setup

**Checklist**:
- [ ] Menu text visible
- [ ] Subscriber count shows
- [ ] 'S' opens shop
- [ ] 'ESC' closes shop
- [ ] 'SPACE' starts run
- [ ] No visual glitches

**Result**: [ ] PASS  [ ] FAIL

**Issues Found**:
```
[Document any issues]
```

---

### Step 3: Shop UI Verification (CRITICAL)

**Test Actions**:
1. From main menu, press 'S'
2. Observe shop rendering
3. Look for upgrade cards
4. Check for tabs

**What Should Happen** (After My Fix):
- ✅ Visual upgrade cards with icons
- ✅ Four tabs: Upgrades, Characters, Trucks, Levels
- ✅ Subscriber count in header
- ✅ Footer with controls
- ❌ NO "(Shop UI to be implemented)" text

**What Would Fail** (Before My Fix):
- ❌ Stub text: "(Shop UI to be implemented)"
- ❌ No visual cards
- ❌ No tabs

**Checklist**:
- [ ] Shop renders properly
- [ ] Upgrade cards visible
- [ ] Icons show (🚀, 📈, ⚡, etc.)
- [ ] Tabs visible
- [ ] Subscriber count accurate
- [ ] NO stub text present

**Result**: [ ] PASS  [ ] FAIL

**Screenshot**: (Take screenshot if possible)

---

### Step 4: Gameplay Loop

**Test Actions**:
1. Press 'SPACE' from main menu → Enter setup
2. Hold 'SPACE' → Charge power meter
3. Release 'SPACE' → Launch vehicle
4. Observe vehicle movement
5. Watch for ragdoll collisions
6. Wait for vehicle to stop
7. Observe results screen

**What Should Happen**:
- Setup scene shows vehicle and ragdolls
- Power meter appears and charges
- Vehicle launches on release
- Vehicle has physics (moves, falls)
- Ragdolls are visible
- Collisions produce damage numbers
- Score accumulates
- Vehicle eventually stops
- Results screen appears

**Checklist**:
- [ ] Setup scene renders
- [ ] Vehicle visible
- [ ] Ragdolls visible (3 of them)
- [ ] Ground/walls visible
- [ ] Power meter shows
- [ ] Meter charges when holding SPACE
- [ ] Vehicle launches on release
- [ ] Vehicle physics works
- [ ] Ragdolls have physics
- [ ] Collisions detect
- [ ] Damage numbers appear
- [ ] Score accumulates
- [ ] Combo counter works
- [ ] Run completes (vehicle stops)
- [ ] Results screen shows

**Result**: [ ] PASS  [ ] FAIL

**Issues Found**:
```
[Document any issues]
```

---

### Step 5: Collision & Damage System

**Test Actions**:
1. During gameplay, observe collisions
2. Look for damage numbers
3. Check combo counter
4. Watch score increase

**What Should Happen**:
- Vehicle hits ragdoll → damage number floats up
- Repeated hits → combo multiplier increases (2x, 3x, etc.)
- Score increases with each hit
- Bigger hits → bigger damage numbers
- Camera shakes on impact
- Particles spawn on impact

**Checklist**:
- [ ] Collisions detect
- [ ] Damage numbers appear
- [ ] Damage values seem reasonable (10-200)
- [ ] Combo system works
- [ ] Score increases
- [ ] Camera shakes
- [ ] Particles spawn
- [ ] Screen flash (big hits)
- [ ] Slow motion (massive hits)

**Result**: [ ] PASS  [ ] FAIL

---

### Step 6: Results & Progression

**Test Actions**:
1. Complete a run (vehicle stops)
2. Observe results screen
3. Note score and subscribers earned
4. Press 'SPACE' or 'S' to continue

**What Should Happen**:
- Results screen appears automatically
- Shows final score
- Shows subscribers earned (score / 100)
- Shows total subscribers
- Can press 'SPACE' to retry or 'S' for shop

**Checklist**:
- [ ] Results screen appears
- [ ] Score displays
- [ ] Subscribers earned displays
- [ ] Total subscribers displays
- [ ] Can navigate from results

**Result**: [ ] PASS  [ ] FAIL

---

### Step 7: Save/Load System

**Test Actions**:
1. Complete one run
2. Note total subscriber count
3. Close game completely
4. Re-launch game
5. Check if subscriber count persists

**What Should Happen**:
- After run completes, subscribers saved
- Game closes cleanly
- Game re-launches
- Main menu shows saved subscriber count
- Progress persists

**Checklist**:
- [ ] Subscribers earned from run
- [ ] Game closes without errors
- [ ] Game re-launches successfully
- [ ] Subscriber count persists
- [ ] Save file created (check for .json or .sav)

**Result**: [ ] PASS  [ ] FAIL

**Save File Location**:
```
[Document where save file is created]
```

---

### Step 8: Achievement System

**Test Actions**:
1. Complete first run
2. Look for achievement notification
3. Check console for achievement unlocks

**What Should Happen**:
- First run → "First Blood" achievement unlocks
- Notification slides in from right
- Shows achievement name and description
- Notification auto-dismisses after 4s
- Console prints achievement unlock

**Checklist**:
- [ ] Achievement unlocks on first run
- [ ] Notification appears
- [ ] Notification slides in smoothly
- [ ] Shows achievement details
- [ ] Auto-dismisses
- [ ] Console confirms unlock

**Result**: [ ] PASS  [ ] FAIL

---

### Step 9: Shop Purchase (Expected to Fail)

**Test Actions**:
1. Open shop ('S' from menu)
2. Try clicking on an upgrade card
3. Observe if anything happens

**What's Expected**:
- ❌ Clicking does nothing (not implemented yet)
- ✅ Shop renders properly (my fix)
- ✅ Shows upgrade costs

**This is EXPECTED to not work** - purchase interaction still needs implementation.

**Checklist**:
- [ ] Shop renders (should work)
- [ ] Upgrade cards visible (should work)
- [ ] Clicking does nothing (expected)
- [ ] No crash when clicking (important)

**Result**: [ ] As Expected  [ ] Unexpected

---

### Step 10: Performance Check

**Test Actions**:
1. During gameplay, observe frame rate
2. Check for stuttering or lag
3. Press F1 to toggle debug info
4. Check FPS counter

**What Should Happen**:
- Smooth 60 FPS
- No noticeable lag
- No stuttering
- Debug info shows performance stats

**Checklist**:
- [ ] 60 FPS maintained
- [ ] No stuttering
- [ ] No lag spikes
- [ ] Debug info accessible (F1)
- [ ] Performance acceptable

**Result**: [ ] PASS  [ ] FAIL

---

## 📊 TEST RESULTS SUMMARY

### Critical Systems:

| System | Status | Notes |
|--------|--------|-------|
| Game Launches | [ ] PASS [ ] FAIL | |
| Main Menu | [ ] PASS [ ] FAIL | |
| Shop Rendering | [ ] PASS [ ] FAIL | (My fix) |
| Gameplay Loop | [ ] PASS [ ] FAIL | |
| Collisions | [ ] PASS [ ] FAIL | |
| Score System | [ ] PASS [ ] FAIL | |
| Results Screen | [ ] PASS [ ] FAIL | |
| Save/Load | [ ] PASS [ ] FAIL | |
| Achievements | [ ] PASS [ ] FAIL | |
| Performance | [ ] PASS [ ] FAIL | |

### Overall Result:
- Tests Passed: __ / 10
- Tests Failed: __ / 10
- **Grade**: ___

---

## 🐛 ISSUES DISCOVERED

### Critical Issues (Prevents Gameplay):
```
1. [Issue description]
   - Error message:
   - Expected vs actual:
   - Fix needed:

2. [Issue description]
   ...
```

### High Priority Issues (Major Problems):
```
1. [Issue description]
2. [Issue description]
```

### Medium Priority Issues (Minor Problems):
```
1. [Issue description]
2. [Issue description]
```

### Low Priority Issues (Polish):
```
1. [Issue description]
2. [Issue description]
```

---

## ✅ SUCCESS CRITERIA

### Minimum Viable (Alpha-Ready):
- [x] Game launches without errors
- [x] Main menu accessible
- [x] Can start a run
- [x] Gameplay loop completes
- [x] Collisions work
- [x] Score accumulates
- [x] Results show
- [x] Save persists

**If all above pass**: **ALPHA READY** ✅

### Production Ready (Beta-Ready):
- All minimum viable +
- [x] Shop renders properly
- [x] Achievements unlock
- [x] All states transition
- [x] No crashes
- [x] 60 FPS stable
- [x] Purchase interaction works (needs implementation)

**If all above pass**: **BETA READY** ✅

---

## 🔧 POST-TEST ACTIONS

### If Tests Pass (8+/10):
1. ✅ Celebrate - game actually works!
2. Implement purchase interaction (30 min)
3. Integrate statistics UI (30 min)
4. Polish and test edge cases
5. Consider Week 6 (Steam prep)

### If Tests Mostly Pass (5-7/10):
1. Fix critical issues found
2. Re-test fixed systems
3. Document remaining issues
4. Prioritize fixes

### If Tests Mostly Fail (0-4/10):
1. Don't panic - expected for first run
2. Fix import errors first
3. Fix runtime errors next
4. Re-test after each fix
5. Document learning

---

## 📝 TEST EXECUTION LOG

**Date**: ___________  
**Tester**: ___________  
**Duration**: ___________  
**Outcome**: ___________

**Overall Assessment**:
```
[Summary of test results]
```

**Next Steps**:
```
[What needs to be done based on results]
```

**Confidence Level After Testing**: ____%

---

**Checklist Status**: Ready to Execute  
**Estimated Time**: 30-60 minutes  
**Required**: Run this test before claiming any completion percentage

*This is the moment of truth. Let's see if it actually works!* 🎮
