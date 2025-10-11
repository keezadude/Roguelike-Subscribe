-- src/rendering/camera-system.lua
-- Dynamic Camera System
-- Follows vehicle with smooth transitions and shake effects

local CameraSystem = {}
CameraSystem.__index = CameraSystem

function CameraSystem:new(options)
    local self = setmetatable({}, CameraSystem)
    
    options = options or {}
    
    -- Camera position
    self.x = options.x or 0
    self.y = options.y or 0
    self.targetX = self.x
    self.targetY = self.y
    
    -- Camera properties
    self.zoom = options.zoom or 1.0
    self.targetZoom = self.zoom
    self.rotation = 0
    
    -- Follow settings
    self.followSpeed = options.followSpeed or 3.0
    self.followOffset = options.followOffset or {x = 0, y = -50}
    self.deadzone = options.deadzone or {x = 100, y = 50}
    self.lookahead = options.lookahead or 100  -- Look ahead in direction of movement
    
    -- Shake effects
    self.shakeX = 0
    self.shakeY = 0
    self.shakeMagnitude = 0
    self.shakeDecay = 10  -- How fast shake fades
    
    -- Bounds
    self.bounds = options.bounds or nil  -- {minX, minY, maxX, maxY}
    
    -- Screen dimensions
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
    
    -- State
    self.target = nil
    self.locked = false
    
    return self
end

function CameraSystem:setTarget(target)
    --[[
        Set entity for camera to follow
        
        @param target: Entity with getPosition() method
    ]]
    
    self.target = target
    
    -- Snap camera to target immediately
    if target then
        local tx, ty = target:getPosition()
        self.x = tx + self.followOffset.x
        self.y = ty + self.followOffset.y
        self.targetX = self.x
        self.targetY = self.y
    end
end

function CameraSystem:update(dt)
    --[[
        Update camera position and effects
        
        @param dt: Delta time
    ]]
    
    -- Update target position
    if self.target and not self.locked then
        local tx, ty = self.target:getPosition()
        
        -- Add lookahead based on velocity
        local vx, vy = 0, 0
        if self.target.getVelocity then
            vx, vy = self.target:getVelocity()
        end
        
        local speed = math.sqrt(vx * vx + vy * vy)
        local lookaheadX = (vx / (speed + 1)) * self.lookahead
        local lookaheadY = (vy / (speed + 1)) * self.lookahead
        
        -- Calculate target with offset and lookahead
        self.targetX = tx + self.followOffset.x + lookaheadX
        self.targetY = ty + self.followOffset.y + lookaheadY
        
        -- Apply deadzone (don't move camera for small movements)
        local dx = self.targetX - self.x
        local dy = self.targetY - self.y
        
        if math.abs(dx) > self.deadzone.x then
            self.x = self.x + (dx - math.sign(dx) * self.deadzone.x) * self.followSpeed * dt
        end
        
        if math.abs(dy) > self.deadzone.y then
            self.y = self.y + (dy - math.sign(dy) * self.deadzone.y) * self.followSpeed * dt
        end
    end
    
    -- Smooth zoom
    if self.zoom ~= self.targetZoom then
        self.zoom = self.zoom + (self.targetZoom - self.zoom) * 5 * dt
    end
    
    -- Apply bounds
    if self.bounds then
        local halfWidth = (self.screenWidth / 2) / self.zoom
        local halfHeight = (self.screenHeight / 2) / self.zoom
        
        self.x = math.max(self.bounds[1] + halfWidth, math.min(self.bounds[3] - halfWidth, self.x))
        self.y = math.max(self.bounds[2] + halfHeight, math.min(self.bounds[4] - halfHeight, self.y))
    end
    
    -- Update shake
    if self.shakeMagnitude > 0 then
        self.shakeMagnitude = self.shakeMagnitude - self.shakeDecay * dt
        
        if self.shakeMagnitude < 0 then
            self.shakeMagnitude = 0
            self.shakeX = 0
            self.shakeY = 0
        else
            -- Random shake offset
            local angle = love.math.random() * math.pi * 2
            self.shakeX = math.cos(angle) * self.shakeMagnitude
            self.shakeY = math.sin(angle) * self.shakeMagnitude
        end
    end
end

function CameraSystem:shake(magnitude, duration)
    --[[
        Apply camera shake effect
        
        @param magnitude: Shake intensity (pixels)
        @param duration: Optional duration (uses magnitude if not specified)
    ]]
    
    self.shakeMagnitude = math.max(self.shakeMagnitude, magnitude)
    
    if duration then
        self.shakeDecay = magnitude / duration
    else
        self.shakeDecay = 10
    end
end

function CameraSystem:setZoom(zoom, smooth)
    --[[
        Set camera zoom level
        
        @param zoom: Zoom multiplier (1.0 = normal, 2.0 = 2x zoom)
        @param smooth: If true, zoom smoothly. If false, snap immediately
    ]]
    
    if smooth then
        self.targetZoom = zoom
    else
        self.zoom = zoom
        self.targetZoom = zoom
    end
end

function CameraSystem:setPosition(x, y, snap)
    --[[
        Manually set camera position
        
        @param x, y: World position
        @param snap: If true, snap immediately. If false, move smoothly
    ]]
    
    if snap then
        self.x = x
        self.y = y
        self.targetX = x
        self.targetY = y
    else
        self.targetX = x
        self.targetY = y
    end
end

function CameraSystem:lock(locked)
    --[[
        Lock camera position (stop following)
        
        @param locked: true to lock, false to unlock
    ]]
    
    self.locked = locked
end

function CameraSystem:setBounds(minX, minY, maxX, maxY)
    --[[
        Set camera movement bounds
        
        @param minX, minY: Top-left corner
        @param maxX, maxY: Bottom-right corner
    ]]
    
    self.bounds = {minX, minY, maxX, maxY}
end

function CameraSystem:getPosition()
    --[[
        Get current camera position
        
        @return: x, y coordinates
    ]]
    
    return self.x + self.shakeX, self.y + self.shakeY
end

function CameraSystem:getTransform()
    --[[
        Get camera transform for rendering
        
        @return: x, y, rotation, zoom
    ]]
    
    local x = self.x + self.shakeX
    local y = self.y + self.shakeY
    
    return x, y, self.rotation, self.zoom
end

function CameraSystem:attach()
    --[[
        Apply camera transformation (call before drawing world)
    ]]
    
    love.graphics.push()
    
    local x, y = self:getPosition()
    
    -- Translate to center of screen
    love.graphics.translate(self.screenWidth / 2, self.screenHeight / 2)
    
    -- Apply zoom
    love.graphics.scale(self.zoom, self.zoom)
    
    -- Apply rotation
    love.graphics.rotate(self.rotation)
    
    -- Translate to camera position
    love.graphics.translate(-x, -y)
end

function CameraSystem:detach()
    --[[
        Remove camera transformation (call after drawing world)
    ]]
    
    love.graphics.pop()
end

function CameraSystem:worldToScreen(worldX, worldY)
    --[[
        Convert world coordinates to screen coordinates
        
        @param worldX, worldY: World position
        @return: Screen position
    ]]
    
    local x, y = self:getPosition()
    
    local screenX = (worldX - x) * self.zoom + self.screenWidth / 2
    local screenY = (worldY - y) * self.zoom + self.screenHeight / 2
    
    return screenX, screenY
end

function CameraSystem:screenToWorld(screenX, screenY)
    --[[
        Convert screen coordinates to world coordinates
        
        @param screenX, screenY: Screen position
        @return: World position
    ]]
    
    local x, y = self:getPosition()
    
    local worldX = (screenX - self.screenWidth / 2) / self.zoom + x
    local worldY = (screenY - self.screenHeight / 2) / self.zoom + y
    
    return worldX, worldY
end

function CameraSystem:isVisible(x, y, margin)
    --[[
        Check if a point is visible on screen
        
        @param x, y: World position
        @param margin: Extra margin around screen
        @return: true if visible
    ]]
    
    margin = margin or 0
    
    local screenX, screenY = self:worldToScreen(x, y)
    
    return screenX >= -margin and screenX <= self.screenWidth + margin and
           screenY >= -margin and screenY <= self.screenHeight + margin
end

-- Helper function
function math.sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

return CameraSystem
