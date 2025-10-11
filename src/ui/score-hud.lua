-- src/ui/score-hud.lua
-- Score HUD Display
-- Shows score, combo, damage numbers, and bonuses during gameplay

local ScoreHUD = {}
ScoreHUD.__index = ScoreHUD

function ScoreHUD:new(scoreManager, options)
    local self = setmetatable({}, ScoreHUD)
    
    self.scoreManager = scoreManager
    options = options or {}
    
    -- Display settings
    self.visible = options.visible ~= false
    self.position = options.position or {x = 10, y = 10}
    
    -- Floating damage numbers
    self.damageNumbers = {}
    self.maxDamageNumbers = 10
    
    -- Combo display
    self.comboFlash = 0
    self.comboScale = 1.0
    
    -- Score animation
    self.displayedScore = 0
    self.scoreAnimSpeed = 100  -- Points per second
    
    -- Colors
    self.colors = {
        score = {1, 1, 1},
        combo = {1, 0.8, 0.2},
        damage = {1, 0.3, 0.3},
        bonus = {0.3, 1, 0.3},
        headshot = {1, 0.5, 0}
    }
    
    return self
end

function ScoreHUD:addDamageNumber(damage, x, y, bonusText)
    --[[
        Add a floating damage number at position
        
        @param damage: Damage amount
        @param x, y: World position where damage occurred
        @param bonusText: Optional bonus text array
    ]]
    
    local damageNumber = {
        damage = damage,
        x = x,
        y = y,
        lifetime = 2.0,
        fadeTime = 0.5,
        velocity = {x = (love.math.random() - 0.5) * 50, y = -100},
        scale = 1.0,
        bonusText = bonusText or {},
        color = self.colors.damage
    }
    
    -- Special color for high damage
    if damage >= 100 then
        damageNumber.color = {1, 0.5, 0}  -- Orange for massive damage
    end
    
    table.insert(self.damageNumbers, damageNumber)
    
    -- Limit number of damage numbers
    if #self.damageNumbers > self.maxDamageNumbers then
        table.remove(self.damageNumbers, 1)
    end
end

function ScoreHUD:update(dt)
    --[[
        Update HUD elements
        
        @param dt: Delta time
    ]]
    
    -- Animate score counter
    local targetScore = self.scoreManager:getScore()
    if self.displayedScore < targetScore then
        self.displayedScore = self.displayedScore + self.scoreAnimSpeed * dt
        if self.displayedScore > targetScore then
            self.displayedScore = targetScore
        end
    end
    
    -- Update damage numbers
    for i = #self.damageNumbers, 1, -1 do
        local num = self.damageNumbers[i]
        
        num.lifetime = num.lifetime - dt
        if num.lifetime <= 0 then
            table.remove(self.damageNumbers, i)
        else
            -- Move upward
            num.y = num.y + num.velocity.y * dt
            num.x = num.x + num.velocity.x * dt
            
            -- Slow down
            num.velocity.y = num.velocity.y * 0.95
            num.velocity.x = num.velocity.x * 0.95
            
            -- Scale animation
            if num.lifetime > 1.5 then
                num.scale = 1.0 + (2.0 - num.lifetime) * 0.5
            elseif num.lifetime < num.fadeTime then
                num.scale = num.lifetime / num.fadeTime
            else
                num.scale = 1.0
            end
        end
    end
    
    -- Combo flash animation
    if self.comboFlash > 0 then
        self.comboFlash = self.comboFlash - dt * 2
    end
    
    -- Combo scale pulse
    local combo = self.scoreManager.combo
    if combo > 0 then
        self.comboScale = 1.0 + math.sin(love.timer.getTime() * 5) * 0.1
    else
        self.comboScale = 1.0
    end
end

function ScoreHUD:draw(camera)
    --[[
        Draw the HUD
        
        @param camera: Optional camera object for damage numbers
    ]]
    
    if not self.visible then
        return
    end
    
    -- Draw damage numbers (in world space if camera provided)
    if camera then
        camera:attach()
        self:drawDamageNumbers()
        camera:detach()
    else
        self:drawDamageNumbers()
    end
    
    -- Draw HUD elements (screen space)
    self:drawScore()
    self:drawCombo()
    self:drawStats()
end

function ScoreHUD:drawScore()
    --[[
        Draw score display
    ]]
    
    local x = self.position.x
    local y = self.position.y
    
    -- Background panel
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, 200, 60)
    
    -- Border
    love.graphics.setColor(0.3, 0.8, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, 200, 60)
    
    -- Score label
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("SCORE", x + 10, y + 5)
    
    -- Score value
    love.graphics.setColor(self.colors.score)
    love.graphics.print(string.format("%d", math.floor(self.displayedScore)), x + 10, y + 25, 0, 1.5)
end

function ScoreHUD:drawCombo()
    --[[
        Draw combo counter
    ]]
    
    local combo = self.scoreManager.combo
    if combo <= 0 then
        return
    end
    
    local x = self.position.x + 220
    local y = self.position.y
    
    -- Combo flash effect
    local flash = math.max(0, self.comboFlash)
    
    -- Background
    love.graphics.setColor(0, 0, 0, 0.7 + flash * 0.3)
    love.graphics.rectangle("fill", x, y, 150, 60)
    
    -- Border (glows with combo)
    love.graphics.setColor(1, 0.8, 0.2, 0.8 + flash * 0.2)
    love.graphics.setLineWidth(2 + flash * 2)
    love.graphics.rectangle("line", x, y, 150, 60)
    
    -- Combo label
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("COMBO", x + 10, y + 5)
    
    -- Combo value with pulse
    love.graphics.push()
    love.graphics.translate(x + 75, y + 35)
    love.graphics.scale(self.comboScale)
    love.graphics.setColor(self.colors.combo)
    love.graphics.print(string.format("x%d", combo), -20, -10, 0, 2.0)
    love.graphics.pop()
    
    -- Combo multiplier
    local multiplier = self.scoreManager:getComboMultiplier()
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.print(string.format("%.1fx", multiplier), x + 10, y + 45, 0, 0.8)
end

function ScoreHUD:drawStats()
    --[[
        Draw additional stats (hits, damage)
    ]]
    
    local stats = self.scoreManager:getStats()
    local x = self.position.x
    local y = self.position.y + 70
    
    -- Compact stats display
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x, y, 200, 40)
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print(string.format("Hits: %d", stats.totalHits), x + 10, y + 5, 0, 0.8)
    love.graphics.print(string.format("Damage: %.0f", stats.totalDamage), x + 10, y + 20, 0, 0.8)
end

function ScoreHUD:drawDamageNumbers()
    --[[
        Draw floating damage numbers
    ]]
    
    for _, num in ipairs(self.damageNumbers) do
        local alpha = math.min(1, num.lifetime / num.fadeTime)
        
        love.graphics.push()
        love.graphics.translate(num.x, num.y)
        love.graphics.scale(num.scale)
        
        -- Shadow
        love.graphics.setColor(0, 0, 0, alpha * 0.5)
        love.graphics.print(string.format("%.0f", num.damage), 2, 2)
        
        -- Damage number
        love.graphics.setColor(num.color[1], num.color[2], num.color[3], alpha)
        love.graphics.print(string.format("%.0f", num.damage), 0, 0)
        
        -- Bonus text
        if #num.bonusText > 0 then
            love.graphics.setColor(self.colors.bonus[1], self.colors.bonus[2], self.colors.bonus[3], alpha)
            for i, text in ipairs(num.bonusText) do
                love.graphics.print(text, 0, 15 + (i - 1) * 12, 0, 0.6)
            end
        end
        
        love.graphics.pop()
    end
end

function ScoreHUD:flashCombo()
    --[[
        Trigger combo flash effect
    ]]
    
    self.comboFlash = 1.0
end

function ScoreHUD:setVisible(visible)
    --[[
        Set HUD visibility
        
        @param visible: true/false
    ]]
    
    self.visible = visible
end

function ScoreHUD:reset()
    --[[
        Reset HUD state
    ]]
    
    self.damageNumbers = {}
    self.displayedScore = 0
    self.comboFlash = 0
    self.comboScale = 1.0
end

return ScoreHUD
