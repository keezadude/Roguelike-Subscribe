-- src/ui/launch-control.lua
-- Launch Control UI
-- Power slider and launch button for vehicle launch system

local LaunchControl = {}
LaunchControl.__index = LaunchControl

function LaunchControl:new(options)
    local self = setmetatable({}, LaunchControl)
    
    options = options or {}
    
    -- UI position
    self.x = options.x or love.graphics.getWidth() - 250
    self.y = options.y or love.graphics.getHeight() - 150
    self.width = options.width or 230
    self.height = options.height or 130
    
    -- Launch power (0.0 to 1.0)
    self.power = 0.5
    self.targetPower = 0.5
    
    -- State
    self.charging = false
    self.chargeDirection = 1  -- 1 for up, -1 for down
    self.chargeSpeed = 0.8     -- Power per second
    self.launched = false
    
    -- Visual
    self.flashIntensity = 0
    self.pulseTime = 0
    
    -- Callbacks
    self.onLaunch = options.onLaunch  -- Called when launched
    
    -- Colors
    self.colors = {
        background = {0.1, 0.1, 0.15, 0.9},
        border = {0.3, 0.5, 0.8, 1},
        powerBar = {0.2, 0.8, 0.3, 1},
        powerBarHigh = {1, 0.5, 0.1, 1},
        text = {1, 1, 1, 1},
        label = {0.7, 0.7, 0.7, 1}
    }
    
    return self
end

function LaunchControl:update(dt)
    --[[
        Update launch control
        
        @param dt: Delta time
    ]]
    
    if self.launched then
        return
    end
    
    -- Auto-charge mode (oscillating power)
    if self.charging then
        self.power = self.power + (self.chargeDirection * self.chargeSpeed * dt)
        
        -- Bounce at limits
        if self.power >= 1.0 then
            self.power = 1.0
            self.chargeDirection = -1
        elseif self.power <= 0.0 then
            self.power = 0.0
            self.chargeDirection = 1
        end
    end
    
    -- Flash animation
    if self.flashIntensity > 0 then
        self.flashIntensity = self.flashIntensity - dt * 2
    end
    
    -- Pulse animation
    self.pulseTime = self.pulseTime + dt
end

function LaunchControl:draw()
    --[[
        Draw launch control UI
    ]]
    
    love.graphics.push()
    
    -- Background panel
    love.graphics.setColor(self.colors.background)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5, 5)
    
    -- Border
    love.graphics.setColor(self.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 5, 5)
    
    -- Title
    love.graphics.setColor(self.colors.text)
    love.graphics.print("LAUNCH CONTROL", self.x + 10, self.y + 10, 0, 1.2)
    
    -- Power percentage
    love.graphics.setColor(self.colors.label)
    love.graphics.print("POWER", self.x + 10, self.y + 35, 0, 0.9)
    
    -- Power value
    local powerPercent = math.floor(self.power * 100)
    love.graphics.setColor(self.colors.text)
    love.graphics.print(string.format("%d%%", powerPercent), self.x + self.width - 50, self.y + 35, 0, 1.5)
    
    -- Power bar
    self:drawPowerBar()
    
    -- Launch button
    self:drawLaunchButton()
    
    -- Instructions
    if not self.launched then
        love.graphics.setColor(self.colors.label)
        love.graphics.print("SPACE to charge | SPACE again to launch", self.x + 10, self.y + self.height - 20, 0, 0.7)
    end
    
    love.graphics.pop()
end

function LaunchControl:drawPowerBar()
    --[[
        Draw power bar slider
    ]]
    
    local barX = self.x + 10
    local barY = self.y + 60
    local barWidth = self.width - 20
    local barHeight = 20
    
    -- Background track
    love.graphics.setColor(0.2, 0.2, 0.3, 1)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight, 3, 3)
    
    -- Power fill
    local fillWidth = barWidth * self.power
    
    -- Color based on power level
    local barColor
    if self.power >= 0.8 then
        barColor = self.colors.powerBarHigh
    else
        barColor = self.colors.powerBar
    end
    
    -- Add flash effect
    if self.flashIntensity > 0 then
        barColor = {
            math.min(1, barColor[1] + self.flashIntensity),
            math.min(1, barColor[2] + self.flashIntensity),
            math.min(1, barColor[3] + self.flashIntensity),
            1
        }
    end
    
    love.graphics.setColor(barColor)
    love.graphics.rectangle("fill", barX, barY, fillWidth, barHeight, 3, 3)
    
    -- Pulse effect when charging
    if self.charging then
        local pulse = math.sin(self.pulseTime * 10) * 0.3 + 0.7
        love.graphics.setColor(1, 1, 1, pulse * 0.3)
        love.graphics.rectangle("fill", barX, barY, fillWidth, barHeight, 3, 3)
    end
    
    -- Border
    love.graphics.setColor(0.5, 0.5, 0.6, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight, 3, 3)
    
    -- Marker lines for power thresholds
    local thresholds = {0.25, 0.5, 0.75}
    love.graphics.setColor(0.4, 0.4, 0.5, 0.5)
    for _, threshold in ipairs(thresholds) do
        local markerX = barX + barWidth * threshold
        love.graphics.line(markerX, barY, markerX, barY + barHeight)
    end
end

function LaunchControl:drawLaunchButton()
    --[[
        Draw launch button
    ]]
    
    local buttonX = self.x + 10
    local buttonY = self.y + 90
    local buttonWidth = self.width - 20
    local buttonHeight = 30
    
    if self.launched then
        -- Disabled state
        love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 3, 3)
        
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight, 3, 3)
        
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.printf("LAUNCHED", buttonX, buttonY + 8, buttonWidth, "center")
    elseif self.charging then
        -- Charging state
        love.graphics.setColor(1, 0.5, 0.1, 0.8)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 3, 3)
        
        love.graphics.setColor(1, 0.7, 0.3, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight, 3, 3)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("RELEASE TO LAUNCH!", buttonX, buttonY + 8, buttonWidth, "center")
    else
        -- Ready state
        love.graphics.setColor(0.2, 0.6, 0.9, 0.8)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 3, 3)
        
        love.graphics.setColor(0.3, 0.8, 1, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight, 3, 3)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("HOLD SPACE TO CHARGE", buttonX, buttonY + 8, buttonWidth, "center")
    end
end

function LaunchControl:startCharging()
    --[[
        Start charging the launch power
    ]]
    
    if self.launched then
        return
    end
    
    self.charging = true
    print("Charging launch power...")
end

function LaunchControl:stopCharging()
    --[[
        Stop charging (returns current power)
    ]]
    
    if not self.charging or self.launched then
        return nil
    end
    
    self.charging = false
    return self.power
end

function LaunchControl:launch()
    --[[
        Execute launch with current power
        
        @return: Power level (0-1)
    ]]
    
    if self.launched then
        return nil
    end
    
    local launchPower = self.power
    self.launched = true
    self.charging = false
    self.flashIntensity = 1.0
    
    print(string.format("LAUNCH! Power: %.0f%%", launchPower * 100))
    
    -- Call callback
    if self.onLaunch then
        self.onLaunch(launchPower)
    end
    
    return launchPower
end

function LaunchControl:setPower(power)
    --[[
        Manually set power level
        
        @param power: Power (0-1)
    ]]
    
    self.power = math.max(0, math.min(1, power))
end

function LaunchControl:getPower()
    --[[
        Get current power level
        
        @return: Power (0-1)
    ]]
    
    return self.power
end

function LaunchControl:reset()
    --[[
        Reset launch control for new attempt
    ]]
    
    self.power = 0.5
    self.charging = false
    self.chargeDirection = 1
    self.launched = false
    self.flashIntensity = 0
    self.pulseTime = 0
end

function LaunchControl:setOnLaunch(callback)
    --[[
        Set launch callback
        
        @param callback: function(power)
    ]]
    
    self.onLaunch = callback
end

return LaunchControl
