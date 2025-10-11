-- src/entities/ragdoll.lua
-- Multi-Body Ragdoll Physics System
-- 5-body ragdoll: head, torso, left arm, right arm, left leg, right leg

local Ragdoll = {}
Ragdoll.__index = Ragdoll

-- Ragdoll body part definitions
Ragdoll.BODY_PARTS = {
    HEAD = "head",
    TORSO = "torso",
    LEFT_ARM = "left_arm",
    RIGHT_ARM = "right_arm",
    LEFT_LEG = "left_leg",
    RIGHT_LEG = "right_leg"
}

-- Body part dimensions (in pixels)
Ragdoll.DIMENSIONS = {
    head = {width = 20, height = 20, shape = "circle", radius = 10},
    torso = {width = 30, height = 40, shape = "rectangle"},
    left_arm = {width = 12, height = 30, shape = "rectangle"},
    right_arm = {width = 12, height = 30, shape = "rectangle"},
    left_leg = {width = 14, height = 35, shape = "rectangle"},
    right_leg = {width = 14, height = 35, shape = "rectangle"}
}

-- Body part masses (kg)
Ragdoll.MASSES = {
    head = 5.0,
    torso = 40.0,
    left_arm = 5.0,
    right_arm = 5.0,
    left_leg = 10.0,
    right_leg = 10.0
}

-- Damage multipliers for different body parts
Ragdoll.DAMAGE_MULTIPLIERS = {
    head = 15.0,
    torso = 8.0,
    left_arm = 3.0,
    right_arm = 3.0,
    left_leg = 5.0,
    right_leg = 5.0
}

function Ragdoll:new(physicsWorld, x, y, options)
    local self = setmetatable({}, Ragdoll)
    
    options = options or {}
    
    -- Ragdoll properties
    self.physicsWorld = physicsWorld
    self.startX = x
    self.startY = y
    
    -- Body parts storage
    self.parts = {}
    self.joints = {}
    
    -- Ragdoll state
    self.alive = true
    self.totalDamage = 0
    self.health = options.health or 100
    self.maxHealth = options.maxHealth or 100
    
    -- Visual properties
    self.colors = {
        head = {0.9, 0.7, 0.6},      -- Skin tone
        torso = {0.3, 0.5, 0.8},     -- Blue shirt
        left_arm = {0.9, 0.7, 0.6},  -- Skin tone
        right_arm = {0.9, 0.7, 0.6}, -- Skin tone
        left_leg = {0.2, 0.2, 0.3},  -- Dark pants
        right_leg = {0.2, 0.2, 0.3}  -- Dark pants
    }
    
    -- 3D model reference (for future 3D rendering)
    self.model = nil
    self.modelPath = options.modelPath
    
    -- Create physics bodies
    self:createBodies()
    
    -- Create joints between bodies
    self:createJoints()
    
    return self
end

function Ragdoll:createBodies()
    --[[
        Create all ragdoll body parts
    ]]
    
    local x = self.startX
    local y = self.startY
    
    -- HEAD
    self.parts.head = self:createBodyPart("head", x, y - 35, {
        density = self.MASSES.head / (math.pi * self.DIMENSIONS.head.radius^2)
    })
    
    -- TORSO (central piece)
    self.parts.torso = self:createBodyPart("torso", x, y, {
        density = self.MASSES.torso / (self.DIMENSIONS.torso.width * self.DIMENSIONS.torso.height)
    })
    
    -- LEFT ARM
    self.parts.left_arm = self:createBodyPart("left_arm", x - 25, y - 10, {
        density = self.MASSES.left_arm / (self.DIMENSIONS.left_arm.width * self.DIMENSIONS.left_arm.height)
    })
    
    -- RIGHT ARM
    self.parts.right_arm = self:createBodyPart("right_arm", x + 25, y - 10, {
        density = self.MASSES.right_arm / (self.DIMENSIONS.right_arm.width * self.DIMENSIONS.right_arm.height)
    })
    
    -- LEFT LEG
    self.parts.left_leg = self:createBodyPart("left_leg", x - 10, y + 40, {
        density = self.MASSES.left_leg / (self.DIMENSIONS.left_leg.width * self.DIMENSIONS.left_leg.height)
    })
    
    -- RIGHT LEG
    self.parts.right_leg = self:createBodyPart("right_leg", x + 10, y + 40, {
        density = self.MASSES.right_leg / (self.DIMENSIONS.right_leg.width * self.DIMENSIONS.right_leg.height)
    })
end

function Ragdoll:createBodyPart(partName, x, y, options)
    --[[
        Create a single body part
        
        @param partName: Name of the body part
        @param x, y: Position
        @param options: Physics options
        @return: Body collider
    ]]
    
    local dims = self.DIMENSIONS[partName]
    options = options or {}
    
    local bodyOptions = {
        shape = dims.shape,
        density = options.density or 1.0,
        friction = 0.5,
        restitution = 0.1,
        category = "ENEMY",  -- Ragdolls count as enemies
        userData = {
            ragdoll = self,
            partName = partName,
            type = "ragdoll_part"
        }
    }
    
    -- Add shape-specific dimensions
    if dims.shape == "circle" then
        bodyOptions.radius = dims.radius
    else
        bodyOptions.width = dims.width
        bodyOptions.height = dims.height
    end
    
    local body = self.physicsWorld:createBody("dynamic", x, y, bodyOptions)
    
    -- Store reference to ragdoll in body
    body.ragdollPart = partName
    body.ragdoll = self
    
    return body
end

function Ragdoll:createJoints()
    --[[
        Create joints connecting body parts
        Uses Breezefield's underlying Box2D joint system
    ]]
    
    -- Get the underlying Box2D world
    local world = self.physicsWorld.world._world
    
    -- HEAD to TORSO (neck joint - ball and socket)
    self.joints.neck = love.physics.newRevoluteJoint(
        self.parts.head.body,
        self.parts.torso.body,
        self.startX, self.startY - 20,
        false  -- don't collide connected bodies
    )
    self.joints.neck:setLimitsEnabled(true)
    self.joints.neck:setLimits(-math.pi/4, math.pi/4)  -- 45 degrees each way
    
    -- LEFT ARM to TORSO (shoulder joint)
    self.joints.left_shoulder = love.physics.newRevoluteJoint(
        self.parts.left_arm.body,
        self.parts.torso.body,
        self.startX - 15, self.startY - 15,
        false
    )
    self.joints.left_shoulder:setLimitsEnabled(true)
    self.joints.left_shoulder:setLimits(-math.pi/2, math.pi)  -- Wide range of motion
    
    -- RIGHT ARM to TORSO (shoulder joint)
    self.joints.right_shoulder = love.physics.newRevoluteJoint(
        self.parts.right_arm.body,
        self.parts.torso.body,
        self.startX + 15, self.startY - 15,
        false
    )
    self.joints.right_shoulder:setLimitsEnabled(true)
    self.joints.right_shoulder:setLimits(-math.pi, math.pi/2)
    
    -- LEFT LEG to TORSO (hip joint)
    self.joints.left_hip = love.physics.newRevoluteJoint(
        self.parts.left_leg.body,
        self.parts.torso.body,
        self.startX - 10, self.startY + 20,
        false
    )
    self.joints.left_hip:setLimitsEnabled(true)
    self.joints.left_hip:setLimits(-math.pi/3, math.pi/3)
    
    -- RIGHT LEG to TORSO (hip joint)
    self.joints.right_hip = love.physics.newRevoluteJoint(
        self.parts.right_leg.body,
        self.parts.torso.body,
        self.startX + 10, self.startY + 20,
        false
    )
    self.joints.right_hip:setLimitsEnabled(true)
    self.joints.right_hip:setLimits(-math.pi/3, math.pi/3)
end

function Ragdoll:update(dt)
    --[[
        Update ragdoll physics and state
        
        @param dt: Delta time
    ]]
    
    if not self.alive then
        return
    end
    
    -- Check if ragdoll is "dead" (health depleted)
    if self.health <= 0 then
        self.alive = false
        self:onDeath()
    end
    
    -- Future: Update 3D model positions based on 2D physics
end

function Ragdoll:draw()
    --[[
        Draw ragdoll (2D placeholder representation)
    ]]
    
    if not self.alive then
        love.graphics.setColor(0.3, 0.3, 0.3, 0.5)  -- Dim if dead
    end
    
    -- Draw each body part
    for partName, body in pairs(self.parts) do
        self:drawBodyPart(partName, body)
    end
    
    -- Draw joints (connection lines)
    self:drawJoints()
end

function Ragdoll:drawBodyPart(partName, body)
    --[[
        Draw a single body part
        
        @param partName: Name of the part
        @param body: Physics body
    ]]
    
    local x, y = body:getPosition()
    local angle = body:getAngle()
    local dims = self.DIMENSIONS[partName]
    local color = self.colors[partName]
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    
    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    if dims.shape == "circle" then
        love.graphics.circle("fill", 2, 2, dims.radius)
    else
        love.graphics.rectangle("fill", 
            -dims.width/2 + 2, 
            -dims.height/2 + 2, 
            dims.width, 
            dims.height)
    end
    
    -- Draw body part
    love.graphics.setColor(color)
    if dims.shape == "circle" then
        love.graphics.circle("fill", 0, 0, dims.radius)
    else
        love.graphics.rectangle("fill", 
            -dims.width/2, 
            -dims.height/2, 
            dims.width, 
            dims.height)
    end
    
    -- Draw outline
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.setLineWidth(1)
    if dims.shape == "circle" then
        love.graphics.circle("line", 0, 0, dims.radius)
    else
        love.graphics.rectangle("line", 
            -dims.width/2, 
            -dims.height/2, 
            dims.width, 
            dims.height)
    end
    
    love.graphics.pop()
end

function Ragdoll:drawJoints()
    --[[
        Draw lines connecting joints
    ]]
    
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.setLineWidth(2)
    
    -- Helper function to draw joint line
    local function drawJointLine(part1, part2)
        local x1, y1 = part1:getPosition()
        local x2, y2 = part2:getPosition()
        love.graphics.line(x1, y1, x2, y2)
    end
    
    -- Draw all connections
    if self.parts.head and self.parts.torso then
        drawJointLine(self.parts.head, self.parts.torso)
    end
    if self.parts.left_arm and self.parts.torso then
        drawJointLine(self.parts.left_arm, self.parts.torso)
    end
    if self.parts.right_arm and self.parts.torso then
        drawJointLine(self.parts.right_arm, self.parts.torso)
    end
    if self.parts.left_leg and self.parts.torso then
        drawJointLine(self.parts.left_leg, self.parts.torso)
    end
    if self.parts.right_leg and self.parts.torso then
        drawJointLine(self.parts.right_leg, self.parts.torso)
    end
end

function Ragdoll:applyImpact(partName, forceX, forceY, damage)
    --[[
        Apply impact force and damage to a specific body part
        
        @param partName: Which body part was hit
        @param forceX, forceY: Impact force vector
        @param damage: Base damage amount (will be multiplied by part multiplier)
    ]]
    
    local part = self.parts[partName]
    if not part then
        return
    end
    
    -- Apply physics impulse
    part:applyLinearImpulse(forceX, forceY)
    
    -- Calculate damage with body part multiplier
    local multiplier = self.DAMAGE_MULTIPLIERS[partName] or 1.0
    local actualDamage = damage * multiplier
    
    self:takeDamage(actualDamage)
    
    print(string.format("Ragdoll hit on %s: %.1f damage (%.1fx multiplier)", 
        partName, actualDamage, multiplier))
end

function Ragdoll:takeDamage(amount)
    --[[
        Apply damage to ragdoll
        
        @param amount: Damage amount
    ]]
    
    self.totalDamage = self.totalDamage + amount
    self.health = math.max(0, self.health - amount)
end

function Ragdoll:getPosition()
    --[[
        Get ragdoll center position (torso position)
        
        @return: x, y coordinates
    ]]
    
    if self.parts.torso then
        return self.parts.torso:getPosition()
    end
    
    return self.startX, self.startY
end

function Ragdoll:getTotalVelocity()
    --[[
        Calculate total kinetic energy of ragdoll
        
        @return: Total kinetic energy
    ]]
    
    local totalEnergy = 0
    
    for partName, body in pairs(self.parts) do
        local vx, vy = body:getLinearVelocity()
        local speed = math.sqrt(vx * vx + vy * vy)
        local mass = self.MASSES[partName]
        local kineticEnergy = 0.5 * mass * (speed * speed)
        
        totalEnergy = totalEnergy + kineticEnergy
    end
    
    return totalEnergy
end

function Ragdoll:onDeath()
    --[[
        Called when ragdoll "dies" (health depleted)
    ]]
    
    print(string.format("Ragdoll died! Total damage: %.1f", self.totalDamage))
    -- Future: trigger death effects, scoring, etc.
end

function Ragdoll:destroy()
    --[[
        Clean up ragdoll (destroy all bodies and joints)
    ]]
    
    -- Destroy joints first
    for _, joint in pairs(self.joints) do
        if joint and not joint:isDestroyed() then
            joint:destroy()
        end
    end
    self.joints = {}
    
    -- Destroy body parts
    for _, body in pairs(self.parts) do
        if body and body.destroy then
            body:destroy()
        end
    end
    self.parts = {}
end

-- Collision callbacks
function Ragdoll:onCollision(partName, other, contact, impulse)
    --[[
        Handle collision with a body part
        
        @param partName: Which part was hit
        @param other: Other collider
        @param contact: Contact object
        @param impulse: Collision impulse
    ]]
    
    -- Calculate damage from collision force
    if impulse then
        local damage = impulse * 0.01  -- Scale factor for damage
        
        -- Only take damage from significant impacts
        if damage > 1.0 then
            self:applyImpact(partName, 0, 0, damage)
        end
    end
end

return Ragdoll
