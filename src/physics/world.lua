-- src/physics/world.lua
-- Physics World Manager - Breezefield Integration
-- Handles physics simulation, collision categories, and callbacks

local PhysicsWorld = {}
PhysicsWorld.__index = PhysicsWorld

-- Collision categories (bitwise flags for filtering)
PhysicsWorld.CATEGORIES = {
    PLAYER = 1,
    ENEMY = 2,
    PROJECTILE = 4,
    WALL = 8,
    PICKUP = 16,
    SENSOR = 32
}

-- Collision masks (what each category collides with)
PhysicsWorld.MASKS = {
    PLAYER = {ENEMY = true, PROJECTILE = true, WALL = true, PICKUP = true},
    ENEMY = {PLAYER = true, PROJECTILE = true, WALL = true, ENEMY = true},
    PROJECTILE = {PLAYER = true, ENEMY = true, WALL = true},
    WALL = {PLAYER = true, ENEMY = true, PROJECTILE = true},
    PICKUP = {PLAYER = true},
    SENSOR = {PLAYER = true, ENEMY = true}
}

function PhysicsWorld:new(gravityX, gravityY, options)
    local self = setmetatable({}, PhysicsWorld)
    
    -- Options with defaults
    options = options or {}
    gravityX = gravityX or 0
    gravityY = gravityY or 0
    
    -- Load Breezefield physics library
    local bf = require('lib.breezefield')
    
    -- Create physics world (gravity scaled to pixels: 9.81 * 64 = 627.84)
    self.world = bf.newWorld(gravityX, gravityY, true)
    
    -- World properties
    self.pixelScale = options.pixelScale or 64  -- pixels per meter
    self.timeStep = options.timeStep or 1/60    -- fixed timestep
    self.velocityIterations = options.velocityIterations or 8
    self.positionIterations = options.positionIterations or 3
    
    -- Collision tracking
    self.collisionCallbacks = {}
    self.activeCollisions = {}
    
    -- Debug options
    self.debugDraw = false
    
    -- Statistics
    self.stats = {
        bodies = 0,
        dynamicBodies = 0,
        staticBodies = 0,
        kinematicBodies = 0,
        collisions = 0,
        updateTime = 0
    }
    
    -- Set up collision callbacks
    self:setupCollisionCallbacks()
    
    return self
end

function PhysicsWorld:setupCollisionCallbacks()
    -- Breezefield uses enter/exit/preSolve/postSolve callbacks
    -- These are set on individual colliders, not the world
    -- We'll provide helper methods to register global callbacks
end

function PhysicsWorld:registerCollisionCallback(category1, category2, callbackType, callback)
    --[[
        Register a collision callback between two categories
        
        @param category1: First collision category (string or number)
        @param category2: Second collision category (string or number)
        @param callbackType: "enter", "exit", "preSolve", or "postSolve"
        @param callback: function(collider1, collider2, contact)
    ]]
    
    local key = string.format("%s_%s_%s", 
        tostring(category1), tostring(category2), callbackType)
    
    self.collisionCallbacks[key] = callback
end

function PhysicsWorld:createBody(bodyType, x, y, options)
    --[[
        Create a physics body (wrapper around Breezefield)
        
        @param bodyType: "dynamic", "static", or "kinematic"
        @param x, y: Initial position
        @param options: {
            shape: "circle" or "rectangle" or "polygon",
            radius: for circle,
            width, height: for rectangle,
            vertices: for polygon,
            category: collision category,
            density: body density,
            friction: surface friction,
            restitution: bounciness (0-1),
            userData: custom data to attach
        }
        
        @return: Breezefield Collider object
    ]]
    
    options = options or {}
    local shape = options.shape or "circle"
    
    local collider
    
    -- Create collider based on shape type using Breezefield API
    -- Format: world:newCollider(type, {args})
    if shape == "circle" then
        local radius = options.radius or 16
        collider = self.world:newCollider("Circle", {x, y, radius})
        
    elseif shape == "rectangle" then
        local width = options.width or 32
        local height = options.height or 32
        collider = self.world:newCollider("Rectangle", {x, y, width, height})
        
    elseif shape == "polygon" then
        local vertices = options.vertices or {-16, -16, 16, -16, 16, 16, -16, 16}
        collider = self.world:newCollider("Polygon", vertices)
        collider:setPosition(x, y)
        
    else
        error("Unknown shape type: " .. tostring(shape))
    end
    
    -- Set body type
    if bodyType == "static" then
        collider:setType("static")
    elseif bodyType == "kinematic" then
        collider:setType("kinematic")
    else
        collider:setType("dynamic")
    end
    
    -- Set physics properties
    if options.density then collider:setDensity(options.density) end
    if options.friction then collider:setFriction(options.friction) end
    if options.restitution then collider:setRestitution(options.restitution) end
    if options.fixedRotation then collider:setFixedRotation(options.fixedRotation) end
    if options.linearDamping then collider:setLinearDamping(options.linearDamping) end
    if options.angularDamping then collider:setAngularDamping(options.angularDamping) end
    
    -- Set collision category
    if options.category then
        collider.category = options.category
    end
    
    -- Attach custom user data
    if options.userData then
        collider.userData = options.userData
    end
    
    -- Update statistics
    self:updateStats()
    
    return collider
end

function PhysicsWorld:destroyBody(collider)
    --[[
        Safely destroy a physics body
        
        @param collider: Breezefield Collider to destroy
    ]]
    
    if collider and collider.destroy then
        collider:destroy()
        self:updateStats()
    end
end

function PhysicsWorld:update(dt)
    --[[
        Update physics simulation
        
        @param dt: Delta time in seconds
    ]]
    
    local startTime = love.timer.getTime()
    
    -- Update physics world with fixed timestep
    self.world:update(dt)
    
    -- Update statistics
    local endTime = love.timer.getTime()
    self.stats.updateTime = (endTime - startTime) * 1000  -- Convert to ms
    
    self:updateStats()
end

function PhysicsWorld:updateStats()
    --[[
        Update world statistics
    ]]
    
    -- Count bodies by type
    local bodies = self.world:getBodies()
    local dynamicCount = 0
    local staticCount = 0
    local kinematicCount = 0
    
    for _, body in ipairs(bodies) do
        local bodyType = body:getType()
        if bodyType == "dynamic" then
            dynamicCount = dynamicCount + 1
        elseif bodyType == "static" then
            staticCount = staticCount + 1
        elseif bodyType == "kinematic" then
            kinematicCount = kinematicCount + 1
        end
    end
    
    self.stats.bodies = #bodies
    self.stats.dynamicBodies = dynamicCount
    self.stats.staticBodies = staticCount
    self.stats.kinematicBodies = kinematicCount
end

function PhysicsWorld:getStats()
    --[[
        Get physics world statistics
        
        @return: Table with statistics
    ]]
    
    return {
        bodies = self.stats.bodies,
        dynamicBodies = self.stats.dynamicBodies,
        staticBodies = self.stats.staticBodies,
        kinematicBodies = self.stats.kinematicBodies,
        updateTime = self.stats.updateTime
    }
end

function PhysicsWorld:setGravity(x, y)
    --[[
        Set world gravity
        
        @param x, y: Gravity vector
    ]]
    
    self.world:setGravity(x, y)
end

function PhysicsWorld:getGravity()
    --[[
        Get current gravity
        
        @return: x, y gravity components
    ]]
    
    return self.world:getGravity()
end

function PhysicsWorld:raycast(x1, y1, x2, y2, callback)
    --[[
        Perform a raycast
        
        @param x1, y1: Start position
        @param x2, y2: End position
        @param callback: function(fixture, x, y, xn, yn, fraction)
        
        @return: Hit result or nil
    ]]
    
    return self.world:rayCast(x1, y1, x2, y2, callback)
end

function PhysicsWorld:queryArea(x, y, radius)
    --[[
        Query a circular area for colliders
        
        @param x, y: Center position
        @param radius: Query radius
        
        @return: Array of colliders in area
    ]]
    
    if self.world.queryCircleArea then
        return self.world:queryCircleArea(x, y, radius)
    else
        return {}
    end
end

function PhysicsWorld:queryRectangle(x1, y1, x2, y2)
    --[[
        Query a rectangular area for colliders
        
        @param x1, y1: Top-left corner
        @param x2, y2: Bottom-right corner
        
        @return: Array of colliders in area
    ]]
    
    if self.world.queryRectangleArea then
        return self.world:queryRectangleArea(x1, y1, x2, y2)
    else
        return {}
    end
end

function PhysicsWorld:clear()
    --[[
        Remove all bodies from the world
    ]]
    
    local bodies = self.world:getBodies()
    for _, body in ipairs(bodies) do
        if body.destroy then
            body:destroy()
        end
    end
    
    self:updateStats()
end

function PhysicsWorld:destroy()
    --[[
        Destroy the physics world
    ]]
    
    self:clear()
    
    if self.world.destroy then
        self.world:destroy()
    end
    
    self.world = nil
end

return PhysicsWorld
