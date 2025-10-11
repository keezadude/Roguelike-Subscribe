# Week 5: Roguelike Systems - Quick Reference

## ✅ Status: COMPLETE

All Week 5 objectives achieved. 30 achievements, enhanced UI, and complete progression tracking.

---

## 🏆 30 Subscribe-Themed Achievements

### Quick List
1. First Subscriber! (1 sub)
2. 100 Subscribers (100 subs)
3. 1K Subs Milestone (1,000 subs)
4. 10K Subs! (10,000 subs)
5. VERIFIED (100,000 subs)
6. Mega Influencer (1,000,000 subs)
7. First Blood (1 run)
8. Viral Content (10K score)
9. Trending Topic (25K score)
10. Going Viral (50K score)
11. Internet Famous (100K score)
12. Engagement Rate (5x combo)
13. Algorithm Boost (10x combo)
14. Going Mainstream (20x combo)
15. Headshot Master (100 headshots)
16. Overkill King (50 overkills)
17. Airborne Artist (25 airborne)
18. Persistent Creator (10 runs)
19. Dedicated Streamer (50 runs)
20. Content Machine (100 runs)
21. First Upgrade (1 upgrade)
22. Max Power (max 1 upgrade)
23. Big Spender (spend 10K)
24. Character Collector (all chars)
25. Truck Enthusiast (all trucks)
26. Completionist (unlock all)
27. Perfect Launch (100% power)
28. One-Shot Wonder (one-hit kill)
29. Untouchable [HIDDEN] (no damage)
30. Speed Demon [HIDDEN] (max speed)

---

## 📁 New Files Created

### Achievement System
**File**: `src/progression/achievement-system.lua`

**Usage**:
```lua
local AchievementSystem = require('src.progression.achievement-system')

-- Create
achievements = AchievementSystem:new(saveManager)

-- Check after run
local stats = {
    subscribers = totalSubs,
    runs = totalRuns,
    single_run_score = score,
    max_combo = maxCombo,
    headshots = headshotCount
}
local newAchievements = achievements:checkAchievements(stats)

-- Manually unlock
achievements:unlock("achievement_id")

-- Query
unlocked = achievements:isUnlocked("first_sub")
count = achievements:getUnlockedCount()
percent = achievements:getCompletionPercentage()
```

### Achievement Notifications
**File**: `src/ui/achievement-notification.lua`

**Usage**:
```lua
local AchievementNotification = require('src.ui.achievement-notification')

-- Create
notification = AchievementNotification:new()

-- Add achievement
notification:notify(achievement)

-- Update and draw
notification:update(dt)
notification:draw()
```

### Enhanced Shop
**File**: `src/ui/shop-ui.lua`

**Features**:
- Visual upgrade cards
- Tabs: Upgrades, Characters, Trucks, Levels
- Affordability indicators
- Level progress display

**Usage**:
```lua
local ShopUI = require('src.ui.shop-ui')

shop = ShopUI:new(progressionManager, saveManager)

shop:update(dt, mouseX, mouseY)
shop:draw()

shop:setTab("upgrades")
```

### Statistics Page
**File**: `src/ui/statistics-ui.lua`

**Tabs**:
- Overview: Total stats, achievement progress
- Achievements: Full gallery
- Detailed Stats: All tracked metrics

**Usage**:
```lua
local StatisticsUI = require('src.ui.statistics-ui')

stats = StatisticsUI:new(saveManager, achievementSystem)

stats:draw()
stats:setTab("achievements")
```

---

## 🎯 Integration Points

### In Game Manager

```lua
-- Add to requires
local AchievementSystem = require('src.progression.achievement-system')
local AchievementNotification = require('src.ui.achievement-notification')

-- Initialize
self.achievementSystem = AchievementSystem:new(self.saveManager)
self.achievementNotification = AchievementNotification:new()

-- On run complete
local newAchievements = self.achievementSystem:checkAchievements(stats)
for _, achievement in ipairs(newAchievements) do
    self.achievementNotification:notify(achievement)
end

-- In update
self.achievementNotification:update(dt)

-- In draw (always on top)
self.achievementNotification:draw()
```

---

## 📊 Achievement Stats to Track

For achievement checking, provide these stats:
```lua
local stats = {
    subscribers = totalSubscribers,
    runs = totalRuns,
    single_run_score = runScore,
    max_combo = maxCombo,
    headshots = headshotCount,
    overkills = overkillCount,
    airborne_hits = airborneHitCount,
    upgrades_purchased = upgradesPurchased,
    max_upgrade = maxUpgradeLevel,
    total_spent = totalSpent,
    unlock_all_characters = allCharsUnlocked,
    unlock_all_trucks = allTrucksUnlocked,
    unlock_everything = everythingUnlocked,
    perfect_launches = perfectLaunchCount,
    one_shot_kills = oneShotKillCount,
    perfect_runs = perfectRunCount,
    max_speed_reached = maxSpeed,
    playtime_hours = playTimeHours
}
```

---

## 🎨 UI Color Coding

### Shop Cards
- **Green**: Maxed out upgrades
- **Gold**: Can afford
- **Gray**: Can't afford
- **Blue**: Unlocked items

### Achievement Cards
- **Gold border**: Unlocked
- **Gray**: Locked
- **Hidden**: Shows "???" until unlocked

---

## 🔧 Steam Integration (Week 6)

**Ready for Steam SDK**:
```lua
-- Enable Steam
achievementSystem:setSteamAvailable(true)

-- Unlock hook is already in place
-- Will call unlockSteamAchievement(id) automatically
```

**Achievement ID Mapping**:
Each achievement has an ID that maps to Steam achievement ID:
- `first_sub` → Steam: "ACH_FIRST_SUB"
- `verified` → Steam: "ACH_VERIFIED"
- etc.

---

## 📈 Testing Checklist

### Achievement System
- [ ] Unlock on correct conditions
- [ ] Save persistence works
- [ ] Hidden achievements stay hidden
- [ ] Progress tracking accurate
- [ ] Notifications appear

### UI
- [ ] Notifications slide smoothly
- [ ] Multiple achievements queue
- [ ] Shop tabs switch
- [ ] Upgrade cards display correctly
- [ ] Stats page shows all data

---

## 💡 Tips

### Achievement Design
- Mix easy/medium/hard
- Track automatically
- Hidden achievements for secrets
- Theme all text

### Notification Timing
- 4 seconds per notification
- One at a time prevents spam
- Queue handles multiple unlocks
- Slide animation feels good

### UI Organization
- Tabs organize content
- Visual cards > lists
- Color coding helps UX
- Progress bars satisfy

---

## 🚀 What's Next

**Week 6 will add**:
- Steam SDK integration
- Audio files and music
- Performance optimization
- Settings menu
- Controller support
- Final polish

---

**Week 5 Complete**: ✅  
**Achievements**: 30/30 implemented  
**UI**: Enhanced and polished  
**Progression**: Complete  

*The roguelike loop is now fully realized!* 🏆🎮✨
