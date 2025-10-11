-- src/ui/statistics-ui.lua
-- Statistics and Progress Tracking Page
-- Shows all player progression and achievements

local StatisticsUI = {}
StatisticsUI.__index = StatisticsUI

function StatisticsUI:new(saveManager, achievementSystem)
    local self = setmetatable({}, StatisticsUI)
    
    self.saveManager = saveManager
    self.achievementSystem = achievementSystem
    
    -- Tab state
    self.currentTab = "overview"  -- overview, achievements, stats
    
    return self
end

function StatisticsUI:draw()
    --[[
        Draw statistics interface
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
    
    -- Content
    if self.currentTab == "overview" then
        self:drawOverview()
    elseif self.currentTab == "achievements" then
        self:drawAchievements()
    elseif self.currentTab == "stats" then
        self:drawDetailedStats()
    end
    
    -- Footer
    self:drawFooter()
end

function StatisticsUI:drawHeader()
    --[[
        Draw header
    ]]
    
    love.graphics.setColor(0.12, 0.12, 0.18)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 80)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("STATISTICS & PROGRESS", 40, 20, 0, 2)
end

function StatisticsUI:drawTabs()
    --[[
        Draw tab buttons
    ]]
    
    local tabs = {
        {id = "overview", name = "Overview", icon = "📊"},
        {id = "achievements", name = "Achievements", icon = "🏆"},
        {id = "stats", name = "Detailed Stats", icon = "📈"}
    }
    
    local tabWidth = 180
    local tabHeight = 40
    local startX = 40
    local startY = 90
    
    for i, tab in ipairs(tabs) do
        local x = startX + (i - 1) * (tabWidth + 10)
        local y = startY
        
        if self.currentTab == tab.id then
            love.graphics.setColor(0.2, 0.5, 0.8)
        else
            love.graphics.setColor(0.15, 0.15, 0.2)
        end
        love.graphics.rectangle("fill", x, y, tabWidth, tabHeight, 5, 5)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(tab.icon .. " " .. tab.name, x + 15, y + 12)
    end
end

function StatisticsUI:drawOverview()
    --[[
        Draw overview statistics
    ]]
    
    local startX = 60
    local startY = 160
    
    -- Get data
    local totalSubs = self.saveManager:getData("totalSubscribers") or 0
    local totalRuns = self.saveManager:getData("totalRuns") or 0
    local highScore = self.saveManager:getData("highScore") or 0
    local achievementProgress = self.achievementSystem:getCompletionPercentage()
    
    -- Main stats panel
    self:drawStatBox("Total Subscribers", string.format("%d", totalSubs), "💰", 
        startX, startY, 300, 100)
    
    self:drawStatBox("Total Runs", string.format("%d", totalRuns), "🎬", 
        startX + 320, startY, 300, 100)
    
    self:drawStatBox("High Score", string.format("%d", highScore), "⭐", 
        startX + 640, startY, 300, 100)
    
    -- Achievement progress
    local achievementY = startY + 120
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", startX, achievementY, 960, 100, 5, 5)
    
    love.graphics.setColor(0.3, 0.6, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", startX, achievementY, 960, 100, 5, 5)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("🏆 Achievement Progress", startX + 20, achievementY + 15, 0, 1.2)
    
    local unlockedCount = self.achievementSystem:getUnlockedCount()
    local totalCount = self.achievementSystem:getTotalCount()
    
    love.graphics.print(string.format("%d / %d Unlocked (%.1f%%)", 
        unlockedCount, totalCount, achievementProgress), 
        startX + 20, achievementY + 45, 0, 1.5)
    
    -- Progress bar
    local barWidth = 920
    local barHeight = 20
    local barX = startX + 20
    local barY = achievementY + 75
    
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight, 3, 3)
    
    love.graphics.setColor(0.3, 0.8, 0.3)
    love.graphics.rectangle("fill", barX, barY, 
        barWidth * (achievementProgress / 100), barHeight, 3, 3)
    
    love.graphics.setColor(0.5, 0.5, 0.6)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight, 3, 3)
    
    -- Unlocks
    local unlockY = achievementY + 120
    self:drawUnlockProgress(startX, unlockY)
end

function StatisticsUI:drawStatBox(label, value, icon, x, y, width, height)
    --[[
        Draw a stat display box
    ]]
    
    -- Background
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)
    
    -- Border
    love.graphics.setColor(0.3, 0.6, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 5, 5)
    
    -- Icon
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(icon, x + 15, y + 15, 0, 2)
    
    -- Label
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print(label, x + 60, y + 20, 0, 0.9)
    
    -- Value
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(value, x + 60, y + 45, 0, 1.8)
end

function StatisticsUI:drawUnlockProgress(startX, startY)
    --[[
        Draw unlock progress
    ]]
    
    local unlockedChars = #self.saveManager:getData("unlockedCharacters")
    local unlockedTrucks = #self.saveManager:getData("unlockedTrucks")
    local unlockedLevels = #self.saveManager:getData("unlockedLevels")
    
    self:drawStatBox("Characters Unlocked", string.format("%d", unlockedChars), "🎭", 
        startX, startY, 300, 100)
    
    self:drawStatBox("Trucks Unlocked", string.format("%d", unlockedTrucks), "🚚", 
        startX + 320, startY, 300, 100)
    
    self:drawStatBox("Levels Unlocked", string.format("%d", unlockedLevels), "🗺️", 
        startX + 640, startY, 300, 100)
end

function StatisticsUI:drawAchievements()
    --[[
        Draw achievement gallery
    ]]
    
    local achievements = self.achievementSystem:getAllAchievements()
    local startX = 60
    local startY = 160
    local cardWidth = 300
    local cardHeight = 100
    local spacing = 20
    
    local col = 0
    local row = 0
    local maxCols = 3
    
    for _, achievement in ipairs(achievements) do
        local x = startX + col * (cardWidth + spacing)
        local y = startY + row * (cardHeight + spacing)
        
        -- Don't show hidden achievements if not unlocked
        if not achievement.hidden or achievement.unlocked then
            self:drawAchievementCard(achievement, x, y, cardWidth, cardHeight)
            
            col = col + 1
            if col >= maxCols then
                col = 0
                row = row + 1
            end
        end
    end
end

function StatisticsUI:drawAchievementCard(achievement, x, y, width, height)
    --[[
        Draw achievement card
    ]]
    
    -- Background
    if achievement.unlocked then
        love.graphics.setColor(0.2, 0.3, 0.5, 0.9)
    else
        love.graphics.setColor(0.15, 0.15, 0.2, 0.6)
    end
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)
    
    -- Border
    if achievement.unlocked then
        love.graphics.setColor(0.8, 0.6, 0.2)
    else
        love.graphics.setColor(0.4, 0.4, 0.5)
    end
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 5, 5)
    
    -- Icon and name
    if achievement.unlocked then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(achievement.icon, x + 15, y + 15, 0, 2)
        love.graphics.print(achievement.name, x + 60, y + 20, 0, 1.1)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("🔒", x + 15, y + 15, 0, 2)
        love.graphics.print(achievement.hidden and "???" or achievement.name, 
            x + 60, y + 20, 0, 1.1)
    end
    
    -- Description
    love.graphics.setColor(0.7, 0.7, 0.7)
    local desc = achievement.hidden and not achievement.unlocked and "Hidden achievement" or achievement.description
    love.graphics.printf(desc, x + 15, y + 50, width - 30, "left", 0, 0.8)
end

function StatisticsUI:drawDetailedStats()
    --[[
        Draw detailed statistics
    ]]
    
    local stats = self.saveManager:getData("stats")
    local startX = 60
    local startY = 160
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Detailed Statistics", startX, startY, 0, 1.5)
    
    if stats then
        local y = startY + 40
        local lineHeight = 30
        
        local statLines = {
            {label = "Total Damage Dealt", value = string.format("%.0f", stats.totalDamage or 0), icon = "💥"},
            {label = "Total Hits", value = string.format("%d", stats.totalHits or 0), icon = "🎯"},
            {label = "Max Combo", value = string.format("%dx", stats.maxCombo or 0), icon = "⚡"},
            {label = "Headshots", value = string.format("%d", stats.headshots or 0), icon = "🎯"},
            {label = "Perfect Launches", value = string.format("%d", stats.perfectLaunches or 0), icon = "🚀"}
        }
        
        for _, stat in ipairs(statLines) do
            self:drawStatLine(stat.icon, stat.label, stat.value, startX, y, 800)
            y = y + lineHeight
        end
    end
end

function StatisticsUI:drawStatLine(icon, label, value, x, y, width)
    --[[
        Draw a single stat line
    ]]
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, 25, 3, 3)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(icon .. " " .. label, x + 10, y + 5)
    
    love.graphics.print(value, x + width - 100, y + 5)
end

function StatisticsUI:drawFooter()
    --[[
        Draw footer
    ]]
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local footerY = screenHeight - 60
    
    love.graphics.setColor(0.12, 0.12, 0.18)
    love.graphics.rectangle("fill", 0, footerY, screenWidth, 60)
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("ESC to return to menu", 40, footerY + 20)
end

function StatisticsUI:setTab(tabId)
    --[[
        Switch tab
        
        @param tabId: Tab identifier
    ]]
    
    self.currentTab = tabId
end

return StatisticsUI
