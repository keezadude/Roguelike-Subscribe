# 🔧 PRE-TEST FIX LIST
## Prioritized Fixes Required Before Integration Testing
**Date:** 2025-10-11  
**Priority Order:** Critical → High → Medium → Low  
**Total Estimated Time:** 2.5 - 15 hours (depending on scope)

---

## 🚨 CRITICAL FIXES (Must Complete Before Any Testing)

### FIX #1: Point Game to Correct Main File
**Priority:** CRITICAL  
**Estimated Time:** 2 minutes  
**Blocks Testing:** YES  
**Dependencies:** None

#### Problem
The game currently runs `main.lua` which loads the Week 0 library test instead of the actual game.

#### Fix Steps
1. **Backup old main.lua**
   ```batch
   move main.lua main_library_test.lua
   ```

2. **Rename integrated main**
   ```batch
   move main_integrated.lua main.lua
   ```

3. **Verify**
   - Open `main.lua`
   - Confirm line 9 has: `local GameManager = require('src.game.game-manager')`
   - Confirm title on line 18: `"Roguelike & Subscribe"`

#### Verification Test
```batch
cd "c:\Users\kylea\OneDrive\Desktop\GAME_DEV\LOVE2D Project\Roguelike & Subscribe"
love .
```
- Should see "Roguelike & Subscribe" title
- Should NOT see "Library Test"

#### Success Criteria
- Game window opens with proper title
- Main menu displays
- No library test code runs

---

### FIX #2: Implement Shop Click Handling
**Priority:** CRITICAL  
**Estimated Time:** 2-3 hours  
**Blocks Testing:** Shop functionality  
**Dependencies:** None

#### Problem
Shop UI displays but clicking on items does nothing. `getItemAtPosition()` always returns `nil`.

#### Fix Steps

**Step 1: Implement getItemAtPosition() (30 min)**

Open `src/ui/shop-ui.lua`, replace lines 330-340:

```lua
function ShopUI:getItemAtPosition(mouseX, mouseY)
    --[[
        Get item ID at mouse position
        
        @param mouseX, mouseY: Mouse coordinates
        @return: Item ID or nil
    ]]
    
    local startX = 40
    local startY = 150
    local col = 0
    local row = 0
    
    -- Check based on current tab
    if self.currentTab == "upgrades" then
        for upgradeId, upgrade in pairs(self.progressionManager.UPGRADES) do
            local x = startX + col * (self.cardWidth + self.cardSpacing)
            local y = startY + row * (self.cardHeight + self.cardSpacing) - self.scrollOffset
            
            -- Check if mouse is over this card
            if mouseX >= x and mouseX <= x + self.cardWidth and
               mouseY >= y and mouseY <= y + self.cardHeight then
                return upgradeId
            end
            
            col = col + 1
            if col >= self.cardsPerRow then
                col = 0
                row = row + 1
            end
        end
    elseif self.currentTab == "characters" or self.currentTab == "trucks" or self.currentTab == "levels" then
        local category = self.currentTab
        local unlockables = self.progressionManager.UNLOCKABLES[category]
        
        for itemId, item in pairs(unlockables) do
            local x = startX + col * (self.cardWidth + self.cardSpacing)
            local y = startY + row * (self.cardHeight + self.cardSpacing)
            
            if mouseX >= x and mouseX <= x + self.cardWidth and
               mouseY >= y and mouseY <= y + self.cardHeight then
                return itemId
            end
            
            col = col + 1
            if col >= self.cardsPerRow then
                col = 0
                row = row + 1
            end
        end
    end
    
    return nil
end
```

**Step 2: Add mousepressed handler (45 min)**

Add this function before the `return ShopUI` line in `shop-ui.lua`:

```lua
function ShopUI:mousepressed(x, y, button)
    --[[
        Handle mouse clicks
        
        @param x, y: Mouse position
        @param button: Mouse button (1 = left click)
    ]]
    
    if button ~= 1 then return end  -- Only left click
    
    local itemId = self:getItemAtPosition(x, y)
    if not itemId then return end
    
    -- Handle purchase based on tab
    if self.currentTab == "upgrades" then
        self:purchaseUpgrade(itemId)
    elseif self.currentTab == "characters" then
        self:purchaseUnlock("character", itemId)
    elseif self.currentTab == "trucks" then
        self:purchaseUnlock("truck", itemId)
    elseif self.currentTab == "levels" then
        self:purchaseUnlock("level", itemId)
    end
end

function ShopUI:purchaseUpgrade(upgradeId)
    --[[
        Attempt to purchase an upgrade
    ]]
    
    local upgrade = self.progressionManager.UPGRADES[upgradeId]
    if not upgrade then return end
    
    local currentLevel = self.saveManager:upgradeLevel(upgradeId)
    
    -- Check if maxed
    if currentLevel >= upgrade.maxLevel then
        print("❌ Upgrade already maxed out")
        return
    end
    
    -- Get cost
    local cost = self.progressionManager:getUpgradeCost(upgradeId)
    if not cost then return end
    
    -- Check if can afford
    local subscribers = self.saveManager:getData("totalSubscribers") or 0
    if subscribers < cost then
        print(string.format("❌ Not enough subscribers! Need %d, have %d", cost, subscribers))
        return
    end
    
    -- Purchase
    if self.saveManager:spendSubscribers(cost) then
        self.saveManager:purchaseUpgrade(upgradeId)
        self.saveManager:save()
        print(string.format("✅ Purchased %s (Level %d → %d)", 
            upgrade.name, currentLevel, currentLevel + 1))
    end
end

function ShopUI:purchaseUnlock(category, itemId)
    --[[
        Attempt to purchase an unlock
    ]]
    
    local unlockables = self.progressionManager.UNLOCKABLES[category .. "s"]
    local item = unlockables[itemId]
    if not item then return end
    
    -- Check if already unlocked
    local singularCategory = category
    if self.saveManager:hasUnlock(singularCategory, itemId) then
        print("ℹ Already unlocked")
        return
    end
    
    -- Check cost
    local subscribers = self.saveManager:getData("totalSubscribers") or 0
    if subscribers < item.cost then
        print(string.format("❌ Not enough subscribers! Need %d, have %d", item.cost, subscribers))
        return
    end
    
    -- Purchase
    if self.saveManager:spendSubscribers(item.cost) then
        if category == "character" then
            self.saveManager:unlockCharacter(itemId)
        elseif category == "truck" then
            self.saveManager:unlockTruck(itemId)
        elseif category == "level" then
            table.insert(self.saveManager.data.unlockedLevels, itemId)
        end
        
        self.saveManager:save()
        print(string.format("✅ Unlocked %s!", item.name))
    end
end
```

**Step 3: Wire up to game-manager (15 min)**

Open `src/game/game-manager.lua`, find SHOP state registration (line 160), add mousepressed callback:

```lua
-- SHOP
sm:registerState(sm.STATES.SHOP, {
    enter = function()
        print("Entered: SHOP")
    end,
    update = function(dt)
        local mx, my = love.mouse.getPosition()
        self.shopUI:update(dt, mx, my)
    end,
    draw = function()
        self:drawShop()
    end,
    keypressed = function(key)
        if key == "escape" then
            sm:setState(sm.STATES.MAIN_MENU)
        end
    end,
    mousepressed = function(x, y, button)  -- ← ADD THIS
        self.shopUI:mousepressed(x, y, button)
    end
})
```

**Step 4: Test tab switching (30 min)**

Add tab click detection to `shop-ui.lua:mousepressed()` at the start:

```lua
function ShopUI:mousepressed(x, y, button)
    if button ~= 1 then return end
    
    -- Check if clicking on tabs (before item checks)
    local tabs = {
        {id = "upgrades", name = "Upgrades"},
        {id = "characters", name = "Characters"},
        {id = "trucks", name = "Trucks"},
        {id = "levels", name = "Levels"}
    }
    
    local tabWidth = 150
    local tabHeight = 40
    local startX = 40
    local startY = 90
    
    for i, tab in ipairs(tabs) do
        local tx = startX + (i - 1) * (tabWidth + 10)
        local ty = startY
        
        if x >= tx and x <= tx + tabWidth and y >= ty and y <= ty + tabHeight then
            self:setTab(tab.id)
            return
        end
    end
    
    -- ... rest of existing code
```

#### Verification Test
1. Run game
2. Press 'S' to enter shop
3. Click on tabs - should switch
4. Click on upgrade card - should purchase (if enough subscribers)
5. Check console for confirmation messages

#### Success Criteria
- ✅ Tabs switch on click
- ✅ Items can be purchased
- ✅ Subscriber count decreases
- ✅ Upgrade levels increase
- ✅ Appropriate error messages if can't afford

---

### FIX #3: First Test Run & Save Verification
**Priority:** CRITICAL  
**Estimated Time:** 30 minutes  
**Blocks Testing:** Confidence in save system  
**Dependencies:** Fix #1

#### Problem
No save files exist = game has never been successfully run to completion.

#### Test Steps

**Step 1: Complete Full Game Loop**
1. Run game
2. Press SPACE to start
3. Charge launch (hold SPACE)
4. Release to launch
5. Watch collision and scoring
6. Wait for run to end (vehicle stops)
7. View results screen
8. Press ESC to return to menu
9. Press ESC again to quit

**Step 2: Verify Save File**
```batch
cd "c:\Users\kylea\OneDrive\Desktop\GAME_DEV\LOVE2D Project\Roguelike & Subscribe"
dir /s save_data.json
```

Should find file in LOVE2D save directory (typically `%APPDATA%\LOVE\Roguelike & Subscribe\`)

**Step 3: Inspect Save Data**
```batch
type "%APPDATA%\LOVE\Roguelike & Subscribe\save_data.json"
```

Should see JSON with:
- totalSubscribers (increased)
- totalRuns (> 0)
- totalScore (> 0)
- highScore (> 0)

**Step 4: Test Save Persistence**
1. Note subscriber count
2. Quit game
3. Restart game
4. Check subscriber count matches

#### Success Criteria
- ✅ Save file created
- ✅ Data persists across restarts
- ✅ Subscribers carry over
- ✅ Stats are recorded
- ✅ No crash on save/load

---

## ⚠️ HIGH PRIORITY FIXES (Recommended Before Testing)

### FIX #4: Make Missing Assets More Obvious
**Priority:** HIGH  
**Estimated Time:** 1 hour  
**Blocks Testing:** NO  
**Dependencies:** None

#### Problem
Game will use placeholder graphics silently if sprites aren't exported.

#### Fix Steps

**Option A: Warning Banner (Simpler - 30 min)**

Add to `game-manager.lua` draw function:

```lua
function GameManager:draw()
    self.stateMachine:draw()
    
    if self.debugMode then
        self.debugRenderer:draw()
    end
    
    -- Week 5: Draw achievement notifications (always on top)
    self.achievementNotification:draw()
    
    -- ← ADD THIS: Warning banner if using placeholders
    if not self.hasRealAssets then
        love.graphics.setColor(1, 0.5, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 30)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("⚠️ USING PLACEHOLDER GRAPHICS - Export UI components from design/ui-design", 10, 8)
        love.graphics.setColor(1, 1, 1)
    end
end
```

Add flag in initialization:

```lua
function GameManager:initializeSystems()
    -- ... existing code ...
    
    -- Check if using real assets
    local assetCount = 0
    local assetDir = love.filesystem.getInfo("assets/images/ui/")
    if assetDir then
        local files = love.filesystem.getDirectoryItems("assets/images/ui/")
        assetCount = #files
    end
    
    self.hasRealAssets = assetCount > 5  -- Arbitrary threshold
    
    if not self.hasRealAssets then
        print("⚠️ WARNING: Using placeholder graphics")
    end
end
```

**Option B: Asset Loader Check (Better - 1 hour)**

Modify `src/ui/assets-loader.lua:143-147` to return status and track in game-manager.

#### Verification Test
- Run game without exported sprites
- Should see warning banner
- Export sprites
- Warning should disappear

#### Success Criteria
- ✅ Warning visible when using placeholders
- ✅ Warning disappears with real assets
- ✅ Still playable either way

---

## 🔵 OPTIONAL FIXES (UI Enhancements)

### FIX #5: Integrate Main Menu UI System
**Priority:** MEDIUM  
**Estimated Time:** 4 hours  
**Blocks Testing:** NO  
**Dependencies:** None

#### Problem
Beautiful main menu UI exists (`main-menu.lua`) but game uses basic print statements.

#### Decision Point
**Option A:** Use existing basic menu (works, looks ugly)  
**Option B:** Integrate proper UI (looks good, takes time)

If choosing Option B:

#### Fix Steps

**Step 1: Import MainMenu (15 min)**

In `game-manager.lua`, add to requires:
```lua
local MainMenu = require('src.ui.main-menu')
```

Add to initialization:
```lua
function GameManager:initializeSystems()
    -- ... existing systems ...
    
    -- Main Menu UI
    self.mainMenu = MainMenu:new({
        onStartGame = function()
            self.stateMachine:setState(self.stateMachine.STATES.SETUP)
        end,
        onOpenShop = function()
            self.stateMachine:setState(self.stateMachine.STATES.SHOP)
        end,
        onQuit = function()
            love.event.quit()
        end
    })
end
```

**Step 2: Update MAIN_MENU State (15 min)**

```lua
sm:registerState(sm.STATES.MAIN_MENU, {
    enter = function()
        print("Entered: MAIN MENU")
    end,
    update = function(dt)
        local mx, my = love.mouse.getPosition()
        self.mainMenu:update(dt, mx, my)
    end,
    draw = function()
        self.mainMenu:draw()
        
        -- Add subscriber count
        local subs = self.saveManager:getData("totalSubscribers")
        love.graphics.print(string.format("Total Subscribers: %d", subs), 500, 550)
    end,
    keypressed = function(key)
        if key == "escape" then
            love.event.quit()
        end
        -- Let main menu handle other keys
    end,
    mousepressed = function(x, y, button)
        self.mainMenu:mousepressed(x, y, button)
    end
})
```

**Step 3: Remove old drawMainMenu (5 min)**

Delete or comment out `game-manager.lua:620-633`.

**Step 4: Fix MainMenu TODO (2 hours)**

Open `src/ui/main-menu.lua`:
- Implement button sprite loading (line 20)
- Replace TODOs with proper callbacks
- Test button interactions

#### Success Criteria
- ✅ Animated menu buttons
- ✅ Hover effects work
- ✅ Buttons trigger correct actions
- ✅ Professional appearance

---

### FIX #6: Integrate Statistics UI
**Priority:** MEDIUM  
**Estimated Time:** 2 hours  
**Blocks Testing:** NO  
**Dependencies:** None

#### Problem
Complete statistics screen exists but no way to access it.

#### Fix Steps

**Step 1: Add to game-manager (same as Fix #5)**

Import and initialize StatisticsUI similar to ShopUI.

**Step 2: Add State**

Register new STATISTICS state in state machine.

**Step 3: Add Menu Option**

Add "View Stats" button to main menu or results screen.

#### Success Criteria
- ✅ Statistics screen accessible
- ✅ Shows all progression data
- ✅ Achievements visible

---

## 🟢 LOW PRIORITY FIXES (Polish)

### FIX #7: Add Debug Flag System
**Priority:** LOW  
**Estimated Time:** 2 hours  
**Blocks Testing:** NO

#### Problem
Excessive print() statements clutter console.

#### Fix Steps

Create `src/debug/debug-config.lua`:
```lua
local Debug = {
    enabled = true,
    
    categories = {
        state = true,
        collision = true,
        score = true,
        shop = true,
        save = false,
        audio = false
    }
}

function Debug:log(category, message)
    if not self.enabled then return end
    if not self.categories[category] then return end
    print(string.format("[%s] %s", category:upper(), message))
end

return Debug
```

Replace print statements:
```lua
-- OLD:
print("Entered: SHOP")

-- NEW:
Debug:log("state", "Entered: SHOP")
```

---

## 📋 FIX EXECUTION PLAN

### Minimum Viable (2.5 hours)
1. **Fix #1** - Correct main.lua (2 min)
2. **Fix #2** - Shop clicks (2-3 hrs)
3. **Fix #3** - Test run (30 min)

**Result:** Functional game, ugly UI, works

---

### Recommended (6.5 hours)
1. Minimum Viable (above)
2. **Fix #4** - Asset warnings (1 hr)
3. **Fix #5** - Main Menu UI (4 hrs)

**Result:** Functional game, good UI, professional

---

### Complete (15 hours)
1. Recommended (above)
2. **Fix #6** - Statistics UI (2 hrs)
3. **Fix #7** - Debug system (2 hrs)
4. Additional polish

**Result:** Production-ready game

---

## ✅ VERIFICATION CHECKLIST

After each fix, verify:
- [ ] Game launches without errors
- [ ] Fixed feature works as expected
- [ ] No new bugs introduced
- [ ] Save system still works
- [ ] Console shows expected output

---

## 🎯 RECOMMENDED APPROACH

### Phase 1: Get It Running (2.5 hrs)
Complete Critical Fixes #1-3 first. Test thoroughly.

### Phase 2: Decide on UI (Decision Point)
- Keep basic UI → Done, start testing gameplay
- Upgrade UI → Continue to Phase 3

### Phase 3: Polish (8 hrs)
If time allows, complete High Priority and Optional fixes.

---

## 🚨 CRITICAL PATH

**Bare Minimum to Test Core Gameplay:**
1. Fix #1 (2 min)
2. Fix #3 (30 min)
3. Skip Fix #2 (shop not critical for core gameplay)

**Time to First Test:** 32 minutes

**To Test Everything:**
All Critical Fixes: 2.5-4 hours

---

*Fix list created based on systematic code audit.*  
*All time estimates conservative (worst-case scenarios).*  
*Fixes are independent unless dependencies noted.*
