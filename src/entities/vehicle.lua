-- src/entities/vehicle.lua
-- Vehicle Physics System (Truck with Wheels)
-- Multi-body vehicle with realistic wheel physics

local Vehicle = {}
Vehicle.__index = Vehicle

-- Vehicle specifications
Vehicle.SPECS = {
    -- Truck body
    bodyWidth = 80,
    bodyHeight = 40,
    bodyMass = 1500,  -- 1.5 tons (kg)
    
    -- Wheels
    wheelRadius = 12,
    wheelMass = 50,  -- kg per wheel
    wheelFriction = 0.9,
    wheelDensity = 1.5,
    
    -- Suspension
    suspensionFrequency = 4.0,  -- Hz
    suspensionDamping = 0.7,
    
    -- Physics
    maxSpeed = 500,  -- pixels/second
    enginePower = 150000,  -- Force for acceleration
    brakePower = 100000,  -- Braking force
}

function Vehicle:new(physicsWorld, x, y, options)
    local self = setmetatable({}, Vehicle)
    
    options = options or {}
    
    -- Vehicle properties
    self.physicsWorld = physicsWorld
    self.startX = x
    self.startY = y
    
    -- Bodies
    self.chassis = nil  -- Main truck body
    self.wheels = {}    -- 4 wheels
    self.joints = {}    -- Wheel joints (suspension)
    
    -- Vehicle state
    self.launched = false
    self.launchPower = 0  -- 0-1 scale
    self.speed = 0
    
    -- Control state
    self.accelerating = false
    self.braking = false
    self.steering = 0  -- -1 (left) to 1 (right)
    
    -- Visual properties
    self.chassisColor = options.chassisColor or {0.8, 0.2, 0.2}  -- Red truck
    self.wheelColor = options.wheelColor or {0.1, 0.1, 0.1}  -- Black wheels
    
    -- 3D model reference
    self.model = nil
    self.modelPath = options.modelPath
    
    -- Statistics
    self.maxSpeedReached = 0
    self.distanceTraveled = 0
    self.airTime = 0
    self.onGround = false
    
    -- Create vehicle physics
    self:createChassis()
    self:createWheels()
    self:createSuspension()
    
    return self
end

function Vehicle:createChassis()
    --[[
        Create main truck body (chassis)
    ]]
    
    local specs = self.SPECS
    
    self.chassis = self.physicsWorld:createBody("dynamic", self.startX, self.startY, {
        shape = "rectangle",
        width = specs.bodyWidth,
        height = specs.bodyHeight,
        density = specs.bodyMass / (specs.bodyWidth * specs.bodyHeight),
        friction = 0.5,
        restitution = 0.2,
        category = "WALL",  -- Vehicles act like walls for collision purposes
        userData = {
            vehicle = self,
            type = "vehicle_chassis"
        }
    })
    
    self.chassis.vehicle = self
    self.chassis.vehiclePart = "chassis"
end

function Vehicle:createWheels()
    --[[
        Create 4 wheels for the truck
    ]]
    
    local specs = self.SPECS
    local chassisX, chassisY = self.chassis:getPosition()
    
    -- Wheel positions relative to chassis
    local wheelOffsets = {
        frontLeft = {x = specs.bodyWidth/2 - 10, y = specs.bodyHeight/2 + 5},
        frontRight = {x = specs.bodyWidth/2 - 10, y = -specs.bodyHeight/2 - 5},
        rearLeft = {x = -specs.bodyWidth/2 + 10, y = specs.bodyHeight/2 + 5},
        rearRight = {x = -specs.bodyWidth/2 + 10, y = -specs.bodyHeight/2 - 5}
    }
    
    -- Create each wheel
    for wheelName, offset in pairs(wheelOffsets) do
        local wheelX = chassisX + offset.x
        local wheelY = chassisY + offset.y
        
        local wheel = self.physicsWorld:createBody("dynamic", wheelX, wheelY, {
            shape = "circle",
            radius = specs.wheelRadius,
            density = specs.wheelDensity,
            friction = specs.wheelFriction,
            restitution = 0.3,
            category = "WALL",
            userData = {
                vehicle = self,
                type = "vehicle_wheel",
                wheelName = wheelName
            }
        })
        
        wheel.vehicle = self
        wheel.vehiclePart = "wheel"
        wheel.wheelName = wheelName
        
        self.wheels[wheelName] = wheel
    end
end

function Vehicle:createSuspension()
    --[[
        Create suspension joints connecting wheels to chassis
    ]]
    
    local specs = self.SPECS
    local world = self.physicsWorld.world._world
    
    -- Get chassis position
    local chassisX, chassisY = self.chassis:getPosition()
    
    -- Wheel joint positions
    local jointPositions = {
        frontLeft = {x = chassisX + specs.bodyWidth/2 - 10, y = chassisY + specs.bodyHeight/2},
        frontRight = {x = chassisX + specs.bodyWidth/2 - 10, y = chassisY - specs.bodyHeight/2},
        rearLeft = {x = chassisX - specs.bodyWidth/2 + 10, y = chassisY + specs.bodyHeight/2},
        rearRight = {x = chassisX - specs.bodyWidth/2 + 10, y = chassisY - specs.bodyHeight/2}
    }
    
    -- Create wheel joints (prismatic for suspension travel)
    for wheelName, wheel in pairs(self.wheels) do
        local pos = jointPositions[wheelName]
        
        -- Create revolute joint for rotation + wheel joint for suspension
        -- Using revolute joint for simplicity (allows wheel rotation and suspension)
        local joint = love.physics.newWheelJoint(
            self.chassis.body,
            wheel.body,
            pos.x, pos.y,
            0, 1,  -- Axis (vertical for suspension)
            false  -- Don't collide connected bodies
        )
        
        -- Set suspension properties
        joint:setSpringFrequency(specs.suspensionFrequency)
        joint:setSpringDampingRatio(specs.suspensionDamping)
        
        self.joints[wheelName] = joint
    end
end

function Vehicle:launch(power)
    --[[
        Launch the vehicle with specified power
        
        @param power: Launch power (0.0 to 1.0)
    ]]
    
    power = math.max(0, math.min(1, power))  -- Clamp 0-1
    self.launchPower = power
    self.launched = true
    
    -- Calculate launch force
    local launchForce = power * self.SPECS.enginePower
    
    -- Apply horizontal impulse to chassis
    self.chassis:applyLinearImpulse(launchForce, 0)
    
    -- Apply some upward force for a more dramatic launch
    local liftForce = power * self.SPECS.enginePower * 0.2
    self.chassis:applyLinearImpulse(0, -liftForce)
    
    print(string.format("Vehicle launched at %.0f%% power (force: %.0f)", power * 100, launchForce))
end

function Vehicle:update(dt)
    --[[
        Update vehicle physics and state
        
        @param dt: Delta time
    ]]
    
    -- Update speed
    local vx, vy = self.chassis:getLinearVelocity()
    self.speed = math.sqrt(vx * vx + vy * vy)
    
    -- Track max speed
    if self.speed > self.maxSpeedReached then
        self.maxSpeedReached = self.speed
    end
    
    -- Track distance traveled
    self.distanceTraveled = self.distanceTraveled + self.speed * dt
    
    -- Check if on ground (wheels touching something)
    self.onGround = self:checkWheelsOnGround()
    
    if not self.onGround then
        self.airTime = self.airTime + dt
    end
    
    -- Apply motor torque to wheels if accelerating
    if self.accelerating and self.launched then
        self:applyMotorForce(dt)
    end
    
    -- Apply braking
    if self.braking then
        self:applyBrakes(dt)
    end
    
    -- Limit max speed
    if self.speed > self.SPECS.maxSpeed then
        local scale = self.SPECS.maxSpeed / self.speed
        self.chassis:setLinearVelocity(vx * scale, vy * scale)
    end
end

function Vehicle:applyMotorForce(dt)
    --[[
        Apply engine force to wheels
    ]]
    
    local force = self.SPECS.enginePower * 0.01  -- Continuous force
    
    -- Apply to rear wheels (rear-wheel drive)
    for wheelName, wheel in pairs(self.wheels) do
        if wheelName == "rearLeft" or wheelName == "rearRight" then
            wheel:applyForce(force, 0)
        end
    end
end

function Vehicle:applyBrakes(dt)
    --[[
        Apply braking force
    ]]
    
    local vx, vy = self.chassis:getLinearVelocity()
    local brakeForce = self.SPECS.brakePower * dt
    
    -- Apply opposite force
    if math.abs(vx) > 0.1 then
        local brakeFx = -math.sign(vx) * brakeForce
        self.chassis:applyForce(brakeFx, 0)
    end
end

function Vehicle:checkWheelsOnGround()
    --[[
        Check if any wheels are touching the ground
        
        @return: true if on ground
    ]]
    
    for wheelName, wheel in pairs(self.wheels) do
        -- Check if wheel has active contacts
        local contacts = wheel:getContacts()
        for _, contact in ipairs(contacts) do
            if contact:isTouching() then
                return true
            end
        end
    end
    
    return false
end

function Vehicle:draw()
    --[[
        Draw the vehicle (2D placeholder representation)
    ]]
    
    -- Draw chassis
    self:drawChassis()
    
    -- Draw wheels
    for wheelName, wheel in pairs(self.wheels) do
        self:drawWheel(wheel)
    end
end

function Vehicle:drawChassis()
    --[[
        Draw truck chassis
    ]]
    
    local x, y = self.chassis:getPosition()
    local angle = self.chassis:getAngle()
    local specs = self.SPECS
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 
        -specs.bodyWidth/2 + 3, 
        -specs.bodyHeight/2 + 3, 
        specs.bodyWidth, 
        specs.bodyHeight)
    
    -- Chassis body
    love.graphics.setColor(self.chassisColor)
    love.graphics.rectangle("fill", 
        -specs.bodyWidth/2, 
        -specs.bodyHeight/2, 
        specs.bodyWidth, 
        specs.bodyHeight)
    
    -- Cab (front section)
    love.graphics.setColor(self.chassisColor[1] * 0.7, self.chassisColor[2] * 0.7, self.chassisColor[3] * 0.7)
    love.graphics.rectangle("fill", 
        specs.bodyWidth/2 - 25, 
        -specs.bodyHeight/2, 
        25, 
        specs.bodyHeight)
    
    -- Window
    love.graphics.setColor(0.3, 0.5, 0.7, 0.8)
    love.graphics.rectangle("fill", 
        specs.bodyWidth/2 - 22, 
        -specs.bodyHeight/2 + 5, 
        18, 
        specs.bodyHeight - 10)
    
    -- Outline
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 
        -specs.bodyWidth/2, 
        -specs.bodyHeight/2, 
        specs.bodyWidth, 
        specs.bodyHeight)
    
    love.graphics.pop()
end

function Vehicle:drawWheel(wheel)
    --[[
        Draw a wheel
    ]]
    
    local x, y = wheel:getPosition()
    local angle = wheel:getAngle()
    local radius = self.SPECS.wheelRadius
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.circle("fill", 2, 2, radius)
    
    -- Tire
    love.graphics.setColor(self.wheelColor)
    love.graphics.circle("fill", 0, 0, radius)
    
    -- Rim
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.circle("fill", 0, 0, radius * 0.6)
    
    -- Tread line (shows rotation)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setLineWidth(2)
    love.graphics.line(0, 0, radius, 0)
    
    -- Outline
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(1)
    love.graphics.circle("line", 0, 0, radius)
    
    love.graphics.pop()
end

function Vehicle:getPosition()
    --[[
        Get vehicle position (chassis position)
        
        @return: x, y coordinates
    ]]
    
    return self.chassis:getPosition()
end

function Vehicle:getVelocity()
    --[[
        Get vehicle velocity
        
        @return: vx, vy components
    ]]
    
    return self.chassis:getLinearVelocity()
end

function Vehicle:getKineticEnergy()
    --[[
        Calculate total kinetic energy of vehicle
        
        @return: Kinetic energy in joules
    ]]
    
    local totalEnergy = 0
    
    -- Chassis kinetic energy
    local vx, vy = self.chassis:getLinearVelocity()
    local chassisSpeed = math.sqrt(vx * vx + vy * vy)
    local chassisEnergy = 0.5 * self.SPECS.bodyMass * (chassisSpeed * chassisSpeed)
    totalEnergy = totalEnergy + chassisEnergy
    
    -- Wheel kinetic energy
    for wheelName, wheel in pairs(self.wheels) do
        local wx, wy = wheel:getLinearVelocity()
        local wheelSpeed = math.sqrt(wx * wx + wy * wy)
        local wheelEnergy = 0.5 * self.SPECS.wheelMass * (wheelSpeed * wheelSpeed)
        totalEnergy = totalEnergy + wheelEnergy
    end
    
    return totalEnergy
end

function Vehicle:getStats()
    --[[
        Get vehicle statistics
        
        @return: Stats table
    ]]
    
    return {
        speed = self.speed,
        maxSpeed = self.maxSpeedReached,
        distance = self.distanceTraveled,
        airTime = self.airTime,
        kineticEnergy = self:getKineticEnergy(),
        launched = self.launched,
        launchPower = self.launchPower,
        onGround = self.onGround
    }
end

function Vehicle:reset()
    --[[
        Reset vehicle to starting position
    ]]
    
    -- Reset chassis
    self.chassis:setPosition(self.startX, self.startY)
    self.chassis:setAngle(0)
    self.chassis:setLinearVelocity(0, 0)
    self.chassis:setAngularVelocity(0)
    
    -- Reset wheels
    local chassisX, chassisY = self.chassis:getPosition()
    local specs = self.SPECS
    
    local wheelOffsets = {
        frontLeft = {x = specs.bodyWidth/2 - 10, y = specs.bodyHeight/2 + 5},
        frontRight = {x = specs.bodyWidth/2 - 10, y = -specs.bodyHeight/2 - 5},
        rearLeft = {x = -specs.bodyWidth/2 + 10, y = specs.bodyHeight/2 + 5},
        rearRight = {x = -specs.bodyWidth/2 + 10, y = -specs.bodyHeight/2 - 5}
    }
    
    for wheelName, wheel in pairs(self.wheels) do
        local offset = wheelOffsets[wheelName]
        wheel:setPosition(chassisX + offset.x, chassisY + offset.y)
        wheel:setAngle(0)
        wheel:setLinearVelocity(0, 0)
        wheel:setAngularVelocity(0)
    end
    
    -- Reset state
    self.launched = false
    self.launchPower = 0
    self.speed = 0
    self.maxSpeedReached = 0
    self.distanceTraveled = 0
    self.airTime = 0
    self.onGround = false
end

function Vehicle:destroy()
    --[[
        Clean up vehicle (destroy all bodies and joints)
    ]]
    
    -- Destroy joints
    for _, joint in pairs(self.joints) do
        if joint and not joint:isDestroyed() then
            joint:destroy()
        end
    end
    self.joints = {}
    
    -- Destroy wheels
    for _, wheel in pairs(self.wheels) do
        if wheel and wheel.destroy then
            wheel:destroy()
        end
    end
    self.wheels = {}
    
    -- Destroy chassis
    if self.chassis and self.chassis.destroy then
        self.chassis:destroy()
    end
    self.chassis = nil
end

-- Helper function
function math.sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

return Vehicle
