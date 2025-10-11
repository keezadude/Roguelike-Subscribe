-- src/entities/wall.lua
-- Static Wall Entity for Collision Testing
-- Simple rectangular collision barriers

local Wall = {}
Wall.__index = Wall

function Wall:new(physicsWorld, x, y, width, height, options)
    local self = setmetatable({}, Wall)
    
    options = options or {}
    
    -- Wall dimensions
    self.width = width or 64
    self.height = height or 64
    
    -- Physics body (static - doesn't move)
    self.body = physicsWorld:createBody("static", x, y, {
        shape = "rectangle",
        width = self.width,
        height = self.height,
        friction = options.friction or 0.5,
        restitution = options.restitution or 0.2,
        category = "WALL",
        userData = self
    })
    
    -- Visual properties
    self.color = options.color or {0.4, 0.4, 0.4}
    self.outlineColor = options.outlineColor or {0.6, 0.6, 0.6}
    self.pattern = options.pattern or "solid"  -- solid, brick, stone
    
    return self
end

function Wall:update(dt)
    --[[
        Walls are static, so no update needed
        
        @param dt: Delta time
    ]]
    
    -- Walls don't need updating (static bodies)
end

function Wall:draw()
    --[[
        Draw the wall
    ]]
    
    local x, y = self.body:getPosition()
    
    -- Calculate corner positions
    local halfWidth = self.width / 2
    local halfHeight = self.height / 2
    
    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 
        x - halfWidth + 2, 
        y - halfHeight + 2, 
        self.width, 
        self.height)
    
    -- Draw wall based on pattern
    if self.pattern == "brick" then
        self:drawBrickPattern(x, y)
    elseif self.pattern == "stone" then
        self:drawStonePattern(x, y)
    else
        self:drawSolid(x, y)
    end
    
    -- Draw outline
    love.graphics.setColor(self.outlineColor)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 
        x - halfWidth, 
        y - halfHeight, 
        self.width, 
        self.height)
end

function Wall:drawSolid(x, y)
    --[[
        Draw solid wall pattern
    ]]
    
    local halfWidth = self.width / 2
    local halfHeight = self.height / 2
    
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", 
        x - halfWidth, 
        y - halfHeight, 
        self.width, 
        self.height)
end

function Wall:drawBrickPattern(x, y)
    --[[
        Draw brick wall pattern
    ]]
    
    local halfWidth = self.width / 2
    local halfHeight = self.height / 2
    local brickHeight = 16
    local brickWidth = 32
    
    -- Base fill
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", 
        x - halfWidth, 
        y - halfHeight, 
        self.width, 
        self.height)
    
    -- Brick lines
    love.graphics.setColor(0.2, 0.2, 0.2, 0.4)
    love.graphics.setLineWidth(1)
    
    -- Horizontal lines
    local currentY = y - halfHeight
    local row = 0
    while currentY < y + halfHeight do
        love.graphics.line(x - halfWidth, currentY, x + halfWidth, currentY)
        
        -- Vertical lines (offset every other row)
        local offset = (row % 2) * (brickWidth / 2)
        local currentX = x - halfWidth + offset
        while currentX < x + halfWidth do
            love.graphics.line(currentX, currentY, currentX, currentY + brickHeight)
            currentX = currentX + brickWidth
        end
        
        currentY = currentY + brickHeight
        row = row + 1
    end
end

function Wall:drawStonePattern(x, y)
    --[[
        Draw stone wall pattern
    ]]
    
    local halfWidth = self.width / 2
    local halfHeight = self.height / 2
    
    -- Base fill
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", 
        x - halfWidth, 
        y - halfHeight, 
        self.width, 
        self.height)
    
    -- Add noise/texture (random dark spots)
    love.math.setRandomSeed(x * y)  -- Consistent pattern per wall
    love.graphics.setColor(0, 0, 0, 0.2)
    
    for i = 1, 10 do
        local rx = x - halfWidth + love.math.random() * self.width
        local ry = y - halfHeight + love.math.random() * self.height
        local size = love.math.random(2, 6)
        love.graphics.circle("fill", rx, ry, size)
    end
    
    love.math.setRandomSeed(os.time())  -- Reset random seed
end

function Wall:getPosition()
    --[[
        Get wall position
        
        @return: x, y coordinates
    ]]
    
    return self.body:getPosition()
end

function Wall:getBounds()
    --[[
        Get wall bounding box
        
        @return: x, y, width, height
    ]]
    
    local x, y = self.body:getPosition()
    return x - self.width/2, y - self.height/2, self.width, self.height
end

function Wall:destroy()
    --[[
        Clean up wall entity
    ]]
    
    if self.body then
        self.body:destroy()
        self.body = nil
    end
end

-- Collision callbacks (optional for walls)
function Wall:enter(other, contact)
    -- Walls don't need to react to collisions
end

function Wall:exit(other, contact)
    -- Walls don't need to react to collisions
end

return Wall
