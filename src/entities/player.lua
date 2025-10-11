-- src/entities/player.lua
-- Player Entity with Physics-Based Movement
-- Top-down WASD movement with friction and damping

local Player = {}
Player.__index = Player

function Player:new(physicsWorld, x, y, options)
    local self = setmetatable({}, Player)
    
    -- Options with defaults
    options = options or {}
    
    -- Movement properties
    self.moveSpeed = options.moveSpeed or 300        -- Acceleration force
    self.maxSpeed = options.maxSpeed or 200          -- Maximum velocity
    self.friction = options.friction or 0.8          -- Surface friction
    self.linearDamping = options.linearDamping or 5  -- Air resistance
    self.radius = options.radius or 16               -- Player collision radius
    
    -- Physics body
    self.body = physicsWorld:createBody("dynamic", x, y, {
        shape = "circle",
        radius = self.radius,
        density = 1.0,
        friction = self.friction,
        restitution = 0.1,
        fixedRotation = true,  -- Don't rotate (top-down view)
        linearDamping = self.linearDamping,
        category = "PLAYER",
        userData = self
    })
    
    -- Player state
    self.health = options.health or 100
    self.maxHealth = options.maxHealth or 100
    self.alive = true
    
    -- Visual properties
    self.color = options.color or {0.2, 0.8, 1.0}
    self.outlineColor = {1, 1, 1}
    
    -- Input state
    self.moveDirection = {x = 0, y = 0}
    
    -- Animation state (for future sprite system)
    self.facing = "down"
    self.moving = false
    
    return self
end

function Player:handleInput()
    --[[
        Handle WASD movement input
    ]]
    
    local dx = 0
    local dy = 0
    
    -- WASD input
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        dy = dy - 1
        self.facing = "up"
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        dy = dy + 1
        self.facing = "down"
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        dx = dx - 1
        self.facing = "left"
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        dx = dx + 1
        self.facing = "right"
    end
    
    -- Normalize diagonal movement
    if dx ~= 0 and dy ~= 0 then
        local magnitude = math.sqrt(dx * dx + dy * dy)
        dx = dx / magnitude
        dy = dy / magnitude
    end
    
    self.moveDirection.x = dx
    self.moveDirection.y = dy
    self.moving = (dx ~= 0 or dy ~= 0)
end

function Player:update(dt)
    --[[
        Update player logic
        
        @param dt: Delta time
    ]]
    
    if not self.alive then
        return
    end
    
    -- Handle input
    self:handleInput()
    
    -- Apply movement force
    if self.moving then
        local forceX = self.moveDirection.x * self.moveSpeed
        local forceY = self.moveDirection.y * self.moveSpeed
        
        self.body:applyForce(forceX, forceY)
    end
    
    -- Enforce max speed
    local vx, vy = self.body:getLinearVelocity()
    local speed = math.sqrt(vx * vx + vy * vy)
    
    if speed > self.maxSpeed then
        local scale = self.maxSpeed / speed
        self.body:setLinearVelocity(vx * scale, vy * scale)
    end
end

function Player:draw()
    --[[
        Draw the player (placeholder graphics)
    ]]
    
    if not self.alive then
        return
    end
    
    local x, y = self.body:getPosition()
    
    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.circle("fill", x + 2, y + 2, self.radius)
    
    -- Draw player circle
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", x, y, self.radius)
    
    -- Draw outline
    love.graphics.setColor(self.outlineColor)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", x, y, self.radius)
    
    -- Draw direction indicator
    if self.moving then
        local indicatorLength = self.radius + 8
        local endX = x + self.moveDirection.x * indicatorLength
        local endY = y + self.moveDirection.y * indicatorLength
        
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.setLineWidth(3)
        love.graphics.line(x, y, endX, endY)
        
        -- Arrowhead
        local angle = math.atan2(self.moveDirection.y, self.moveDirection.x)
        local arrowSize = 6
        local arrow1X = endX - arrowSize * math.cos(angle - math.pi/6)
        local arrow1Y = endY - arrowSize * math.sin(angle - math.pi/6)
        local arrow2X = endX - arrowSize * math.cos(angle + math.pi/6)
        local arrow2Y = endY - arrowSize * math.sin(angle + math.pi/6)
        
        love.graphics.line(endX, endY, arrow1X, arrow1Y)
        love.graphics.line(endX, endY, arrow2X, arrow2Y)
    else
        -- Draw idle indicator (pulsing dot)
        local pulse = (math.sin(love.timer.getTime() * 3) + 1) * 0.5
        love.graphics.setColor(1, 1, 1, 0.5 + pulse * 0.3)
        love.graphics.circle("fill", x, y, 3)
    end
    
    -- Draw health bar
    self:drawHealthBar()
end

function Player:drawHealthBar()
    --[[
        Draw health bar above player
    ]]
    
    local x, y = self.body:getPosition()
    
    local barWidth = self.radius * 2
    local barHeight = 4
    local barX = x - barWidth / 2
    local barY = y - self.radius - 10
    
    -- Background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    -- Health fill
    local healthPercent = self.health / self.maxHealth
    local healthColor = {
        1 - healthPercent,  -- Red increases as health decreases
        healthPercent,      -- Green decreases as health decreases
        0
    }
    
    love.graphics.setColor(healthColor)
    love.graphics.rectangle("fill", barX, barY, barWidth * healthPercent, barHeight)
    
    -- Outline
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
end

function Player:getPosition()
    --[[
        Get player position
        
        @return: x, y coordinates
    ]]
    
    return self.body:getPosition()
end

function Player:setPosition(x, y)
    --[[
        Set player position
        
        @param x, y: New position
    ]]
    
    self.body:setPosition(x, y)
    self.body:setLinearVelocity(0, 0)
end

function Player:takeDamage(amount)
    --[[
        Apply damage to player
        
        @param amount: Damage amount
    ]]
    
    if not self.alive then
        return
    end
    
    self.health = math.max(0, self.health - amount)
    
    if self.health <= 0 then
        self.alive = false
        self:onDeath()
    end
end

function Player:heal(amount)
    --[[
        Heal the player
        
        @param amount: Heal amount
    ]]
    
    if not self.alive then
        return
    end
    
    self.health = math.min(self.maxHealth, self.health + amount)
end

function Player:onDeath()
    --[[
        Called when player dies
    ]]
    
    print("Player died!")
    -- Future: trigger death animation, game over screen, etc.
end

function Player:destroy()
    --[[
        Clean up player entity
    ]]
    
    if self.body then
        self.body:destroy()
        self.body = nil
    end
end

-- Collision callbacks (for Breezefield)
function Player:enter(other, contact)
    --[[
        Called when player collides with something
        
        @param other: Other collider
        @param contact: Contact object
    ]]
    
    -- Future: handle collision enter events
    -- e.g., pickup items, trigger damage, etc.
end

function Player:exit(other, contact)
    --[[
        Called when player stops colliding with something
        
        @param other: Other collider
        @param contact: Contact object
    ]]
    
    -- Future: handle collision exit events
end

function Player:preSolve(other, contact)
    --[[
        Called before collision is resolved
        
        @param other: Other collider
        @param contact: Contact object
    ]]
    
    -- Future: modify collision behavior
    -- e.g., one-way platforms, ghost mode, etc.
end

function Player:postSolve(other, contact, normalImpulse, tangentImpulse)
    --[[
        Called after collision is resolved
        
        @param other: Other collider
        @param contact: Contact object
        @param normalImpulse: Impulse along normal
        @param tangentImpulse: Impulse along tangent
    ]]
    
    -- Future: handle collision impacts
    -- e.g., damage from high-speed collisions, screen shake, etc.
end

return Player
