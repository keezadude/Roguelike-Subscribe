-- src/effects/screen-effects.lua
-- Screen Effects System
-- Manages screen flash, vignette, slowmo, and other fullscreen effects

local ScreenEffects = {}
ScreenEffects.__index = ScreenEffects

function ScreenEffects:new(options)
    local self = setmetatable({}, ScreenEffects)
    
    options = options or {}
    
    -- Flash effect
    self.flashColor = {1, 1, 1}
    self.flashIntensity = 0
    self.flashDecay = 5
    
    -- Vignette effect
    self.vignetteIntensity = 0
    self.vignetteTarget = 0
    self.vignetteColor = {0, 0, 0}
    
    -- Screen shake (additional to camera shake)
    self.screenShakeX = 0
    self.screenShakeY = 0
    self.screenShakeMagnitude = 0
    
    -- Slow motion
    self.timeScale = 1.0
    self.targetTimeScale = 1.0
    
    -- Chromatic aberration
    self.chromaticAberration = 0
    
    -- Enabled effects
    self.enabled = options.enabled ~= false
    
    return self
end

function ScreenEffects:flash(color, intensity, duration)
    --[[
        Create screen flash effect
        
        @param color: {r, g, b} color
        @param intensity: Flash intensity (0-1)
        @param duration: Optional duration
    ]]
    
    if not self.enabled then
        return
    end
    
    self.flashColor = color or {1, 1, 1}
    self.flashIntensity = math.min(1, intensity or 0.5)
    
    if duration then
        self.flashDecay = intensity / duration
    else
        self.flashDecay = 5
    end
end

function ScreenEffects:flashDamage(damage)
    --[[
        Flash based on damage amount
        
        @param damage: Damage amount
    ]]
    
    local intensity = math.min(0.8, damage / 100)
    local color = {1, 0.3, 0.3}  -- Red flash
    
    self:flash(color, intensity, 0.3)
end

function ScreenEffects:flashImpact(force)
    --[[
        Flash based on impact force
        
        @param force: Impact force
    ]]
    
    local intensity = math.min(0.6, force / 1000)
    local color = {1, 1, 1}  -- White flash
    
    self:flash(color, intensity, 0.2)
end

function ScreenEffects:setVignette(intensity, color)
    --[[
        Set vignette effect
        
        @param intensity: Vignette intensity (0-1)
        @param color: Optional color {r, g, b}
    ]]
    
    self.vignetteTarget = intensity
    
    if color then
        self.vignetteColor = color
    end
end

function ScreenEffects:slowMotion(timeScale, duration)
    --[[
        Apply slow motion effect
        
        @param timeScale: Time scale (0.5 = half speed, 0.1 = very slow)
        @param duration: Duration in real seconds
    ]]
    
    self.targetTimeScale = timeScale
    
    if duration then
        -- Schedule return to normal speed
        self.slowMoTimer = duration
    end
end

function ScreenEffects:shake(magnitude)
    --[[
        Add screen shake
        
        @param magnitude: Shake intensity
    ]]
    
    self.screenShakeMagnitude = math.max(self.screenShakeMagnitude, magnitude)
end

function ScreenEffects:update(dt)
    --[[
        Update screen effects
        
        @param dt: Delta time (real time, not scaled)
    ]]
    
    -- Update flash
    if self.flashIntensity > 0 then
        self.flashIntensity = self.flashIntensity - self.flashDecay * dt
        
        if self.flashIntensity < 0 then
            self.flashIntensity = 0
        end
    end
    
    -- Update vignette
    if self.vignetteIntensity ~= self.vignetteTarget then
        local diff = self.vignetteTarget - self.vignetteIntensity
        self.vignetteIntensity = self.vignetteIntensity + diff * 5 * dt
        
        if math.abs(diff) < 0.01 then
            self.vignetteIntensity = self.vignetteTarget
        end
    end
    
    -- Update screen shake
    if self.screenShakeMagnitude > 0 then
        self.screenShakeMagnitude = self.screenShakeMagnitude - 10 * dt
        
        if self.screenShakeMagnitude < 0 then
            self.screenShakeMagnitude = 0
            self.screenShakeX = 0
            self.screenShakeY = 0
        else
            local angle = love.math.random() * math.pi * 2
            self.screenShakeX = math.cos(angle) * self.screenShakeMagnitude
            self.screenShakeY = math.sin(angle) * self.screenShakeMagnitude
        end
    end
    
    -- Update time scale
    if self.timeScale ~= self.targetTimeScale then
        local diff = self.targetTimeScale - self.timeScale
        self.timeScale = self.timeScale + diff * 10 * dt
        
        if math.abs(diff) < 0.01 then
            self.timeScale = self.targetTimeScale
        end
    end
    
    -- Update slow motion timer
    if self.slowMoTimer then
        self.slowMoTimer = self.slowMoTimer - dt
        
        if self.slowMoTimer <= 0 then
            self.targetTimeScale = 1.0
            self.slowMoTimer = nil
        end
    end
end

function ScreenEffects:drawFlash()
    --[[
        Draw flash effect
    ]]
    
    if self.flashIntensity > 0 then
        love.graphics.setColor(
            self.flashColor[1],
            self.flashColor[2],
            self.flashColor[3],
            self.flashIntensity
        )
        
        love.graphics.rectangle("fill", 
            0, 0, 
            love.graphics.getWidth(), 
            love.graphics.getHeight())
        
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function ScreenEffects:drawVignette()
    --[[
        Draw vignette effect (dark edges)
    ]]
    
    if self.vignetteIntensity > 0.01 then
        local width = love.graphics.getWidth()
        local height = love.graphics.getHeight()
        
        -- Simple radial gradient approximation
        local steps = 20
        local maxRadius = math.sqrt(width * width + height * height) / 2
        
        for i = steps, 1, -1 do
            local ratio = i / steps
            local alpha = self.vignetteIntensity * (1 - ratio)
            
            love.graphics.setColor(
                self.vignetteColor[1],
                self.vignetteColor[2],
                self.vignetteColor[3],
                alpha
            )
            
            -- Draw frame
            local inset = (1 - ratio) * maxRadius
            love.graphics.rectangle("line", inset, inset, 
                width - inset * 2, height - inset * 2)
        end
        
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function ScreenEffects:draw()
    --[[
        Draw all screen effects (call after world rendering)
    ]]
    
    if not self.enabled then
        return
    end
    
    -- Draw effects in order
    self:drawVignette()
    self:drawFlash()
end

function ScreenEffects:getTimeScale()
    --[[
        Get current time scale for game logic
        
        @return: Time scale multiplier
    ]]
    
    return self.timeScale
end

function ScreenEffects:getScaledDT(dt)
    --[[
        Get delta time scaled by slow motion
        
        @param dt: Real delta time
        @return: Scaled delta time
    ]]
    
    return dt * self.timeScale
end

function ScreenEffects:getShakeOffset()
    --[[
        Get screen shake offset
        
        @return: x, y offset
    ]]
    
    return self.screenShakeX, self.screenShakeY
end

function ScreenEffects:reset()
    --[[
        Reset all effects to default
    ]]
    
    self.flashIntensity = 0
    self.vignetteIntensity = 0
    self.vignetteTarget = 0
    self.screenShakeMagnitude = 0
    self.timeScale = 1.0
    self.targetTimeScale = 1.0
    self.slowMoTimer = nil
end

return ScreenEffects
