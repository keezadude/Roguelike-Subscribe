-- src/ui/achievement-notification.lua
-- Achievement Notification Pop-up
-- Displays achievement unlocks with animation

local AchievementNotification = {}
AchievementNotification.__index = AchievementNotification

function AchievementNotification:new(options)
    local self = setmetatable({}, AchievementNotification)
    
    options = options or {}
    
    -- Notification queue
    self.queue = {}
    self.currentNotification = nil
    
    -- Display settings
    self.displayDuration = options.displayDuration or 4.0
    self.animationDuration = 0.5
    
    -- Position
    self.x = options.x or love.graphics.getWidth() - 320
    self.y = options.y or 60
    self.width = 300
    self.height = 80
    
    -- Animation state
    self.slideProgress = 0
    self.displayTimer = 0
    
    -- Sound
    self.playSound = options.playSound or true
    
    return self
end

function AchievementNotification:notify(achievement)
    --[[
        Add achievement to notification queue
        
        @param achievement: Achievement table with name, description, icon
    ]]
    
    table.insert(self.queue, {
        name = achievement.name,
        description = achievement.description,
        icon = achievement.icon or "🏆",
        unlocked = true
    })
end

function AchievementNotification:update(dt)
    --[[
        Update notification display
        
        @param dt: Delta time
    ]]
    
    -- If no current notification, check queue
    if not self.currentNotification and #self.queue > 0 then
        self.currentNotification = table.remove(self.queue, 1)
        self.slideProgress = 0
        self.displayTimer = 0
        
        -- Play sound (would integrate with sound manager)
        if self.playSound then
            -- soundManager:playSound("achievement_unlock")
        end
    end
    
    -- Animate current notification
    if self.currentNotification then
        -- Slide in
        if self.slideProgress < 1 then
            self.slideProgress = math.min(1, self.slideProgress + dt / self.animationDuration)
        else
            -- Display
            self.displayTimer = self.displayTimer + dt
            
            -- Slide out after duration
            if self.displayTimer >= self.displayDuration then
                self.slideProgress = math.max(0, self.slideProgress - dt / self.animationDuration)
                
                if self.slideProgress <= 0 then
                    self.currentNotification = nil
                end
            end
        end
    end
end

function AchievementNotification:draw()
    --[[
        Draw notification if active
    ]]
    
    if not self.currentNotification then
        return
    end
    
    -- Calculate slide position
    local slideOffset = (1 - self:easeOutCubic(self.slideProgress)) * (self.width + 20)
    local drawX = self.x + slideOffset
    local drawY = self.y
    
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
    love.graphics.rectangle("fill", drawX, drawY, self.width, self.height, 5, 5)
    
    -- Border with glow
    local glowAlpha = math.sin(love.timer.getTime() * 3) * 0.3 + 0.7
    love.graphics.setColor(0.8, 0.6, 0.2, glowAlpha)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", drawX, drawY, self.width, self.height, 5, 5)
    
    -- Achievement Unlocked header
    love.graphics.setColor(0.8, 0.6, 0.2)
    love.graphics.print("🏆 ACHIEVEMENT UNLOCKED", drawX + 15, drawY + 10, 0, 0.9)
    
    -- Achievement name
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.currentNotification.icon .. " " .. self.currentNotification.name, 
        drawX + 15, drawY + 30, 0, 1.1)
    
    -- Achievement description
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf(self.currentNotification.description, 
        drawX + 15, drawY + 52, self.width - 30, "left", 0, 0.8)
    
    love.graphics.setColor(1, 1, 1)
end

function AchievementNotification:easeOutCubic(t)
    --[[
        Cubic easing function
        
        @param t: Time (0-1)
        @return: Eased value
    ]]
    
    return 1 - math.pow(1 - t, 3)
end

function AchievementNotification:hasNotifications()
    --[[
        Check if there are pending notifications
        
        @return: true if notifications in queue or active
    ]]
    
    return self.currentNotification ~= nil or #self.queue > 0
end

function AchievementNotification:clear()
    --[[
        Clear all notifications
    ]]
    
    self.queue = {}
    self.currentNotification = nil
end

return AchievementNotification
