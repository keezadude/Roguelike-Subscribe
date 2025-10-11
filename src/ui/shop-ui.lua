-- src/ui/shop-ui.lua
-- Enhanced Shop Interface
-- Visual upgrade cards with Subscribe theme

local ShopUI = {}
ShopUI.__index = ShopUI

function ShopUI:new(progressionManager, saveManager)
    local self = setmetatable({}, ShopUI)
    
    self.progressionManager = progressionManager
    self.saveManager = saveManager
    
    -- Tab state
    self.currentTab = "upgrades"  -- upgrades, characters, trucks, levels
    
    -- Scroll state
    self.scrollOffset = 0
    self.maxScroll = 0
    
    -- Selection
    self.selectedItem = nil
    self.hoverItem = nil
    
    -- Visual properties
    self.cardWidth = 250
    self.cardHeight = 120
    self.cardSpacing = 20
    self.cardsPerRow = 3
    
    return self
end

function ShopUI:update(dt, mouseX, mouseY)
    --[[
        Update shop UI
        
        @param dt: Delta time
        @param mouseX, mouseY: Mouse position
    ]]
    
    -- Update hover state
    self.hoverItem = self:getItemAtPosition(mouseX, mouseY)
end

function ShopUI:draw()
    --[[
        Draw shop interface
    ]]
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Background
    love.graphics.setColor(0.08, 0.08, 0.12)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    
    -- Header
    self:drawHeader()
    
    -- Tabs
    self:drawTabs()
    
    -- Content area based on tab
    if self.currentTab == "upgrades" then
        self:drawUpgrades()
    elseif self.currentTab == "characters" then
        self:drawUnlockables("characters")
    elseif self.currentTab == "trucks" then
        self:drawUnlockables("trucks")
    elseif self.currentTab == "levels" then
        self:drawUnlockables("levels")
    end
    
    -- Footer
    self:drawFooter()
end

function ShopUI:drawHeader()
    --[[
        Draw shop header with currency
    ]]
    
    -- Header background
    love.graphics.setColor(0.12, 0.12, 0.18)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 80)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("UPGRADE SHOP", 40, 20, 0, 2)
    
    -- Currency display
    local subscribers = self.saveManager:getData("totalSubscribers") or 0
    love.graphics.setColor(0.8, 0.6, 0.2)
    love.graphics.print("💰", love.graphics.getWidth() - 200, 25, 0, 2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("%d Subscribers", subscribers), 
        love.graphics.getWidth() - 160, 35, 0, 1.2)
end

function ShopUI:drawTabs()
    --[[
        Draw tab buttons
    ]]
    
    local tabs = {
        {id = "upgrades", name = "Upgrades", icon = "⬆️"},
        {id = "characters", name = "Characters", icon = "🎭"},
        {id = "trucks", name = "Trucks", icon = "🚚"},
        {id = "levels", name = "Levels", icon = "🗺️"}
    }
    
    local tabWidth = 150
    local tabHeight = 40
    local startX = 40
    local startY = 90
    
    for i, tab in ipairs(tabs) do
        local x = startX + (i - 1) * (tabWidth + 10)
        local y = startY
        
        -- Tab background
        if self.currentTab == tab.id then
            love.graphics.setColor(0.2, 0.5, 0.8)
        else
            love.graphics.setColor(0.15, 0.15, 0.2)
        end
        love.graphics.rectangle("fill", x, y, tabWidth, tabHeight, 5, 5)
        
        -- Tab text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(tab.icon .. " " .. tab.name, x + 15, y + 12)
    end
end

function ShopUI:drawUpgrades()
    --[[
        Draw upgrade cards
    ]]
    
    local upgrades = self.progressionManager.UPGRADES
    local startX = 40
    local startY = 150
    
    local col = 0
    local row = 0
    
    for upgradeId, upgrade in pairs(upgrades) do
        local x = startX + col * (self.cardWidth + self.cardSpacing)
        local y = startY + row * (self.cardHeight + self.cardSpacing) - self.scrollOffset
        
        self:drawUpgradeCard(upgradeId, upgrade, x, y)
        
        col = col + 1
        if col >= self.cardsPerRow then
            col = 0
            row = row + 1
        end
    end
end

function ShopUI:drawUpgradeCard(upgradeId, upgrade, x, y)
    --[[
        Draw individual upgrade card
    ]]
    
    local currentLevel = self.saveManager:upgradeLevel(upgradeId)
    local cost = self.progressionManager:getUpgradeCost(upgradeId)
    local subscribers = self.saveManager:getData("totalSubscribers") or 0
    local canAfford = cost and subscribers >= cost
    local maxed = currentLevel >= upgrade.maxLevel
    
    -- Card background
    if maxed then
        love.graphics.setColor(0.2, 0.4, 0.2, 0.8)
    elseif self.hoverItem == upgradeId then
        love.graphics.setColor(0.25, 0.25, 0.35)
    else
        love.graphics.setColor(0.18, 0.18, 0.24)
    end
    love.graphics.rectangle("fill", x, y, self.cardWidth, self.cardHeight, 5, 5)
    
    -- Border
    if maxed then
        love.graphics.setColor(0.3, 0.8, 0.3)
    elseif canAfford then
        love.graphics.setColor(0.8, 0.6, 0.2)
    else
        love.graphics.setColor(0.4, 0.4, 0.5)
    end
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, self.cardWidth, self.cardHeight, 5, 5)
    
    -- Icon and name
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(upgrade.icon, x + 10, y + 10, 0, 2)
    love.graphics.print(upgrade.name, x + 40, y + 15, 0, 1.1)
    
    -- Description
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf(upgrade.description, x + 10, y + 45, self.cardWidth - 20, "left", 0, 0.8)
    
    -- Level indicator
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Level %d/%d", currentLevel, upgrade.maxLevel), 
        x + 10, y + 75, 0, 0.9)
    
    -- Cost or MAXED
    if maxed then
        love.graphics.setColor(0.3, 1, 0.3)
        love.graphics.print("MAXED OUT", x + 10, y + 95, 0, 1.1)
    else
        if canAfford then
            love.graphics.setColor(0.8, 0.6, 0.2)
        else
            love.graphics.setColor(0.6, 0.4, 0.4)
        end
        love.graphics.print(string.format("💰 %d", cost), x + 10, y + 95, 0, 1.1)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function ShopUI:drawUnlockables(category)
    --[[
        Draw unlockable items (characters, trucks, levels)
    ]]
    
    local unlockables = self.progressionManager.UNLOCKABLES[category]
    local startX = 40
    local startY = 150
    
    local col = 0
    local row = 0
    
    for itemId, item in pairs(unlockables) do
        local x = startX + col * (self.cardWidth + self.cardSpacing)
        local y = startY + row * (self.cardHeight + self.cardSpacing)
        
        self:drawUnlockCard(category, itemId, item, x, y)
        
        col = col + 1
        if col >= self.cardsPerRow then
            col = 0
            row = row + 1
        end
    end
end

function ShopUI:drawUnlockCard(category, itemId, item, x, y)
    --[[
        Draw unlockable item card
    ]]
    
    local singularCategory = string.sub(category, 1, -2)  -- Remove 's'
    local unlocked = self.saveManager:hasUnlock(singularCategory, itemId)
    local subscribers = self.saveManager:getData("totalSubscribers") or 0
    local canAfford = subscribers >= item.cost
    
    -- Card background
    if unlocked then
        love.graphics.setColor(0.2, 0.3, 0.5, 0.8)
    elseif self.hoverItem == itemId then
        love.graphics.setColor(0.25, 0.25, 0.35)
    else
        love.graphics.setColor(0.18, 0.18, 0.24)
    end
    love.graphics.rectangle("fill", x, y, self.cardWidth, self.cardHeight, 5, 5)
    
    -- Border
    if unlocked then
        love.graphics.setColor(0.3, 0.6, 1)
    elseif canAfford then
        love.graphics.setColor(0.8, 0.6, 0.2)
    else
        love.graphics.setColor(0.4, 0.4, 0.5)
    end
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, self.cardWidth, self.cardHeight, 5, 5)
    
    -- Name
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(item.name, x + 15, y + 15, 0, 1.2)
    
    -- Description
    if item.description then
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf(item.description, x + 15, y + 45, self.cardWidth - 30, "left", 0, 0.8)
    end
    
    -- Status
    if unlocked then
        love.graphics.setColor(0.3, 0.8, 1)
        love.graphics.print("✓ UNLOCKED", x + 15, y + 90, 0, 1.1)
    else
        if item.cost > 0 then
            if canAfford then
                love.graphics.setColor(0.8, 0.6, 0.2)
            else
                love.graphics.setColor(0.6, 0.4, 0.4)
            end
            love.graphics.print(string.format("💰 %d to unlock", item.cost), x + 15, y + 90, 0, 0.9)
        else
            love.graphics.setColor(0.3, 1, 0.3)
            love.graphics.print("FREE", x + 15, y + 90, 0, 1.1)
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

function ShopUI:drawFooter()
    --[[
        Draw footer with controls
    ]]
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local footerY = screenHeight - 60
    
    -- Footer background
    love.graphics.setColor(0.12, 0.12, 0.18)
    love.graphics.rectangle("fill", 0, footerY, screenWidth, 60)
    
    -- Controls
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("CLICK to purchase | ESC to return to menu", 40, footerY + 20)
end

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

function ShopUI:setTab(tabId)
    --[[
        Switch to a different tab
        
        @param tabId: Tab identifier
    ]]
    
    self.currentTab = tabId
    self.scrollOffset = 0
end

function ShopUI:mousepressed(x, y, button)
    --[[
        Handle mouse clicks
        
        @param x, y: Mouse position
        @param button: Mouse button (1 = left click)
    ]]
    
    if button ~= 1 then return end  -- Only left click
    
    -- Check if clicking on tabs first
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
    
    -- Check if clicking on an item
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

return ShopUI
