-- src/debug/physics-renderer.lua
-- Physics Debug Visualization System
-- Renders physics bodies, velocities, contacts, and stats

local PhysicsRenderer = {}
PhysicsRenderer.__index = PhysicsRenderer

-- Color scheme for different collision categories
PhysicsRenderer.CATEGORY_COLORS = {
    PLAYER = {0.2, 0.8, 1.0, 0.6},      -- Cyan
    ENEMY = {1.0, 0.2, 0.2, 0.6},       -- Red
    PROJECTILE = {1.0, 1.0, 0.2, 0.6},  -- Yellow
    WALL = {0.5, 0.5, 0.5, 0.8},        -- Gray
    PICKUP = {0.2, 1.0, 0.2, 0.6},      -- Green
    SENSOR = {1.0, 0.5, 1.0, 0.4}       -- Pink
}

-- Color scheme for body types
PhysicsRenderer.BODY_TYPE_COLORS = {
    static = {0.7, 0.7, 0.7, 0.7},
    dynamic = {0.3, 0.8, 0.3, 0.7},
    kinematic = {0.8, 0.8, 0.3, 0.7}
}

function PhysicsRenderer:new(physicsWorld, options)
    local self = setmetatable({}, PhysicsRenderer)
    
    self.physicsWorld = physicsWorld
    
    -- Debug render options
    options = options or {}
    self.showBodies = options.showBodies ~= false
    self.showVelocities = options.showVelocities ~= false
    self.showContacts = options.showContacts ~= false
    self.showStats = options.showStats ~= false
    self.showAABB = options.showAABB or false
    self.showCenterOfMass = options.showCenterOfMass or false
    
    -- Visual settings
    self.lineWidth = options.lineWidth or 2
    self.velocityScale = options.velocityScale or 0.5
    self.contactPointRadius = options.contactPointRadius or 3
    
    -- Toggle state
    self.enabled = false
    
    return self
end

function PhysicsRenderer:toggle()
    --[[
        Toggle debug rendering on/off
    ]]
    
    self.enabled = not self.enabled
end

function PhysicsRenderer:setEnabled(enabled)
    --[[
        Set debug rendering state
        
        @param enabled: true or false
    ]]
    
    self.enabled = enabled
end

function PhysicsRenderer:drawBody(collider)
    --[[
        Draw a single physics body
        
        @param collider: Breezefield Collider object
    ]]
    
    -- Get color based on category or body type
    local color
    if collider.category and self.CATEGORY_COLORS[collider.category] then
        color = self.CATEGORY_COLORS[collider.category]
    else
        local bodyType = collider:getType()
        color = self.BODY_TYPE_COLORS[bodyType] or {1, 1, 1, 0.5}
    end
    
    love.graphics.setColor(color)
    love.graphics.setLineWidth(self.lineWidth)
    
    -- Draw based on shape type
    local shapeType = collider.collider_type
    
    if shapeType == "Circle" then
        local x, y = collider:getPosition()
        local radius = collider:getRadius()
        
        -- Draw circle outline
        love.graphics.circle("line", x, y, radius)
        
        -- Draw line to show rotation
        local angle = collider:getAngle()
        local endX = x + math.cos(angle) * radius
        local endY = y + math.sin(angle) * radius
        love.graphics.line(x, y, endX, endY)
        
    else
        -- For polygon shapes (including rectangles)
        local points = {collider:getWorldPoints(collider:getPoints())}
        
        if #points >= 4 then
            love.graphics.polygon("line", points)
        end
    end
end

function PhysicsRenderer:drawVelocity(collider)
    --[[
        Draw velocity vector for a body
        
        @param collider: Breezefield Collider object
    ]]
    
    local vx, vy = collider:getLinearVelocity()
    
    -- Only draw if there's significant velocity
    if math.abs(vx) < 0.1 and math.abs(vy) < 0.1 then
        return
    end
    
    local x, y = collider:getPosition()
    
    -- Scale velocity for visualization
    local endX = x + vx * self.velocityScale
    local endY = y + vy * self.velocityScale
    
    -- Draw velocity arrow
    love.graphics.setColor(1, 1, 0, 0.8)  -- Yellow
    love.graphics.setLineWidth(2)
    love.graphics.line(x, y, endX, endY)
    
    -- Draw arrowhead
    local angle = math.atan2(vy, vx)
    local arrowSize = 8
    local arrow1X = endX - arrowSize * math.cos(angle - math.pi/6)
    local arrow1Y = endY - arrowSize * math.sin(angle - math.pi/6)
    local arrow2X = endX - arrowSize * math.cos(angle + math.pi/6)
    local arrow2Y = endY - arrowSize * math.sin(angle + math.pi/6)
    
    love.graphics.line(endX, endY, arrow1X, arrow1Y)
    love.graphics.line(endX, endY, arrow2X, arrow2Y)
end

function PhysicsRenderer:drawAABB(collider)
    --[[
        Draw axis-aligned bounding box
        
        @param collider: Breezefield Collider object
    ]]
    
    local x1, y1, x2, y2 = collider:getBoundingBox()
    
    love.graphics.setColor(0, 1, 1, 0.3)  -- Cyan
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x1, y1, x2 - x1, y2 - y1)
end

function PhysicsRenderer:drawCenterOfMass(collider)
    --[[
        Draw center of mass marker
        
        @param collider: Breezefield Collider object
    ]]
    
    local x, y = collider:getWorldCenter()
    
    love.graphics.setColor(1, 0, 1, 0.8)  -- Magenta
    love.graphics.circle("fill", x, y, 3)
    
    -- Draw crosshair
    love.graphics.line(x - 5, y, x + 5, y)
    love.graphics.line(x, y - 5, x, y + 5)
end

function PhysicsRenderer:drawStats()
    --[[
        Draw physics statistics overlay
    ]]
    
    local stats = self.physicsWorld:getStats()
    
    -- Background panel
    local panelX = 10
    local panelY = 10
    local panelWidth = 250
    local panelHeight = 120
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)
    
    love.graphics.setColor(0.2, 0.8, 1, 1)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight)
    
    -- Draw stats text
    love.graphics.setColor(1, 1, 1, 1)
    local textX = panelX + 10
    local textY = panelY + 10
    local lineHeight = 16
    
    love.graphics.print("PHYSICS DEBUG", textX, textY)
    textY = textY + lineHeight + 5
    
    love.graphics.print(string.format("Total Bodies: %d", stats.bodies), textX, textY)
    textY = textY + lineHeight
    
    love.graphics.print(string.format("  Dynamic: %d", stats.dynamicBodies), textX, textY)
    textY = textY + lineHeight
    
    love.graphics.print(string.format("  Static: %d", stats.staticBodies), textX, textY)
    textY = textY + lineHeight
    
    love.graphics.print(string.format("  Kinematic: %d", stats.kinematicBodies), textX, textY)
    textY = textY + lineHeight
    
    love.graphics.print(string.format("Update Time: %.2fms", stats.updateTime), textX, textY)
    
    -- FPS counter
    local fps = love.timer.getFPS()
    local fpsColor = fps >= 55 and {0, 1, 0} or fps >= 30 and {1, 1, 0} or {1, 0, 0}
    love.graphics.setColor(fpsColor)
    love.graphics.print(string.format("FPS: %d", fps), panelX + panelWidth - 70, panelY + 10)
end

function PhysicsRenderer:drawLegend()
    --[[
        Draw color legend for collision categories
    ]]
    
    local legendX = love.graphics.getWidth() - 160
    local legendY = 10
    local legendWidth = 150
    local itemHeight = 20
    local legendHeight = itemHeight * 7 + 20
    
    -- Background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", legendX, legendY, legendWidth, legendHeight)
    
    love.graphics.setColor(0.2, 0.8, 1, 1)
    love.graphics.rectangle("line", legendX, legendY, legendWidth, legendHeight)
    
    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("CATEGORIES", legendX + 10, legendY + 5)
    
    -- Legend items
    local y = legendY + 25
    for category, color in pairs(self.CATEGORY_COLORS) do
        -- Color box
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", legendX + 10, y, 15, 15)
        
        -- Label
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(category, legendX + 30, y + 2)
        
        y = y + itemHeight
    end
end

function PhysicsRenderer:draw()
    --[[
        Main debug render function
    ]]
    
    if not self.enabled then
        return
    end
    
    -- Get all bodies from physics world
    local bodies = self.physicsWorld.world:getBodies()
    
    -- Get all colliders (Breezefield stores them)
    local colliders = self.physicsWorld.world.colliders
    
    -- Draw each collider
    for _, collider in ipairs(colliders) do
        if self.showBodies then
            self:drawBody(collider)
        end
        
        if self.showAABB then
            self:drawAABB(collider)
        end
        
        if self.showCenterOfMass then
            self:drawCenterOfMass(collider)
        end
        
        if self.showVelocities and collider:getType() == "dynamic" then
            self:drawVelocity(collider)
        end
    end
    
    -- Draw UI overlays
    if self.showStats then
        self:drawStats()
    end
    
    -- Draw legend
    self:drawLegend()
    
    -- Draw instructions
    self:drawInstructions()
end

function PhysicsRenderer:drawInstructions()
    --[[
        Draw keyboard instructions
    ]]
    
    local instructionsY = love.graphics.getHeight() - 80
    local instructions = {
        "F1 - Toggle Physics Debug",
        "F2 - Toggle Velocities",
        "F3 - Toggle AABB",
        "ESC - Pause Menu"
    }
    
    -- Background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 10, instructionsY, 200, 70)
    
    -- Text
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    for i, text in ipairs(instructions) do
        love.graphics.print(text, 15, instructionsY + 5 + (i-1) * 16)
    end
end

function PhysicsRenderer:toggleOption(option)
    --[[
        Toggle a specific render option
        
        @param option: "bodies", "velocities", "contacts", "stats", "aabb", "centerOfMass"
    ]]
    
    if option == "bodies" then
        self.showBodies = not self.showBodies
    elseif option == "velocities" then
        self.showVelocities = not self.showVelocities
    elseif option == "contacts" then
        self.showContacts = not self.showContacts
    elseif option == "stats" then
        self.showStats = not self.showStats
    elseif option == "aabb" then
        self.showAABB = not self.showAABB
    elseif option == "centerOfMass" then
        self.showCenterOfMass = not self.showCenterOfMass
    end
end

return PhysicsRenderer
